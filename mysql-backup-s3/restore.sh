#!/usr/bin/env bash

set -e

. /expand_secrets.sh

expand_secrets

if [ "${S3_IAMROLE:-}" != "true" ]; then
  if [ -z "${S3_ACCESS_KEY_ID:-}" ]; then
    echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
  fi

  if [ -z "${S3_SECRET_ACCESS_KEY:-}" ]; then
    echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
  fi
fi

if [ -z "${S3_BUCKET:-}" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "${DATABASE_HOST:-}" ]; then
  echo "You need to set the DATABASE_HOST environment variable."
  exit 1
fi

if [ -z "${DATABASE_PORT:-}" ]; then
  DATABASE_PORT=3306
fi

if [ -z "${DATABASE_USER:-}" ]; then
  echo "You need to set the DATABASE_USER environment variable."
  exit 1
fi

if [ -z "${DATABASE_PASSWORD:-}" ]; then
  echo "You need to set the DATABASE_PASSWORD environment variable or link to a container named MYSQL."
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "Usage: restore.sh <s3-key-ending-in-.sql-or-.sql.gz|database-name>"
  exit 1
fi

if [ "${S3_IAMROLE:-}" != "true" ]; then
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=${S3_ACCESS_KEY_ID:-}
  export AWS_SECRET_ACCESS_KEY=${S3_SECRET_ACCESS_KEY:-}
  export AWS_DEFAULT_REGION=${S3_REGION:-}
fi

if [ -z "${S3_ENDPOINT:-}" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

if [ -z "${S3_PREFIX:-}" ]; then
  S3_KEY_PREFIX=""
else
  S3_KEY_PREFIX="${S3_PREFIX}/"
fi

DATABASE_HOST_OPTIONS="-h $DATABASE_HOST -P $DATABASE_PORT -u$DATABASE_USER -p$DATABASE_PASSWORD"

# Finds the most recent backup key for a database, relying on the naming
# pattern used by backup.sh: <db>/<year>/<month>/<db>[.version].<timestamp>.sql.gz[.enc]
find_latest_backup() {
  local db=$1

  aws $AWS_ARGS s3 ls "s3://${S3_BUCKET}/${S3_KEY_PREFIX}${db}/" --recursive \
    | awk '{print $4}' \
    | sort \
    | tail -n 1
}

ARG=$1

case "$ARG" in
  *.sql|*.sql.gz|*.sql.enc|*.sql.gz.enc)
    SRC_KEY="${S3_KEY_PREFIX}${ARG}"

    if ! HEAD_OBJECT_ERROR=$(aws $AWS_ARGS s3api head-object --bucket "${S3_BUCKET}" --key "${SRC_KEY}" 2>&1 > /dev/null); then
      echo "Backup file $ARG was not found under ${S3_BUCKET}"
      echo "$HEAD_OBJECT_ERROR" >&2
      exit 1
    fi
    ;;
  *)
    SRC_KEY=$(find_latest_backup "$ARG")

    if [ -z "$SRC_KEY" ]; then
      echo "No backup file was found for database $ARG under ${S3_BUCKET}"
      exit 1
    fi
    ;;
esac

REL_KEY="${SRC_KEY#${S3_KEY_PREFIX}}"
DATABASE_NAME="${REL_KEY%%/*}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

DEST_FILE="${WORK_DIR}/$(basename "$SRC_KEY")"

echo "Downloading ${SRC_KEY} from S3..."

if ! aws $AWS_ARGS s3 cp "s3://${S3_BUCKET}/${SRC_KEY}" "$DEST_FILE"; then
  echo "Error downloading ${SRC_KEY} from S3"
  exit 1
fi

if [[ "$DEST_FILE" == *.enc ]]; then
  if [ -z "${ENCRYPTION_PASSWORD:-}" ]; then
    echo "Backup file is encrypted but the ENCRYPTION_PASSWORD environment variable is not set."
    exit 1
  fi

  echo "Decrypting ${DEST_FILE}"
  openssl enc -aes-256-cbc -d -in "$DEST_FILE" -out "${DEST_FILE%.enc}" -k "$ENCRYPTION_PASSWORD"
  rm "$DEST_FILE"
  DEST_FILE="${DEST_FILE%.enc}"
fi

if [[ "$DEST_FILE" == *.gz ]]; then
  echo "Decompressing ${DEST_FILE}"
  gunzip "$DEST_FILE"
  DEST_FILE="${DEST_FILE%.gz}"
fi

echo "Restoring ${DEST_FILE} into database ${DATABASE_NAME}..."

mysql $DATABASE_HOST_OPTIONS "$DATABASE_NAME" < "$DEST_FILE"

echo "Restore completed"
