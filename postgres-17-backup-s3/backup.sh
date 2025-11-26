#!/usr/bin/env bash

set -eo pipefail

echo "Starting backup at $(date)"

if [ -z "${S3_BUCKET}" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "${POSTGRES_DATABASES}" ]; then
  echo "You need to set the POSTGRES_DATABASES environment variable."
  exit 1
fi

if [ -z "${POSTGRES_HOST}" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ -z "${POSTGRES_USER}" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "${POSTGRES_PASSWORD}" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ -z "${POSTGRES_VERSION}" ]; then
  POSTGRES_VERSION=""
else
  POSTGRES_VERSION=".${POSTGRES_VERSION}"
fi

if [ -z "${S3_ENDPOINT}" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"

if [ -z "${S3_PREFIX}" ]; then
  S3_PREFIX="/"
else
  S3_PREFIX="/${S3_PREFIX}/"
fi

if [ -z "${S3_SUFFIX}" ]; then
  S3_SUFFIX=""
else
  S3_SUFFIX="-${S3_SUFFIX}"
fi

if [ "${POSTGRES_DATABASES}" = "ALL" ]; then
  DB_LIST=$(psql $POSTGRES_HOST_OPTS -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'default';")
else 
  DB_LIST = "${POSTGRES_DATABASES//,/ }"
fi

for DB in $DB_LIST; do
  SRC_FILE=dump.sql.gz
  DEST_FILE=${DB}/$(date +"%Y")/$(date +"%m")/${DB}${POSTGRES_VERSION}.$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz

  echo "Creating dump of ${DB} database from ${POSTGRES_HOST}..."
  if ! pg_dump $POSTGRES_HOST_OPTS "$DB" | gzip > "$SRC_FILE"; then
    >&2 echo "Error creating dump for database: ${DB}"
    continue
  fi

  if [ -n "${ENCRYPTION_PASSWORD}" ]; then
    echo "Encrypting ${SRC_FILE}"
    if ! openssl enc -aes-256-cbc -in "$SRC_FILE" -out "${SRC_FILE}.enc" -k "$ENCRYPTION_PASSWORD"; then
      >&2 echo "Error encrypting ${SRC_FILE}"
      continue
    fi
    rm "$SRC_FILE"
    SRC_FILE="${SRC_FILE}.enc"
    DEST_FILE="${DEST_FILE}.enc"
  fi

  echo "Uploading dump to $S3_BUCKET"
  cat $SRC_FILE | aws $AWS_ARGS s3 cp - "s3://${S3_BUCKET}${S3_PREFIX}${DEST_FILE}" || exit 2

  echo "SQL backup uploaded successfully"
  echo "Uploaded to s3://${S3_BUCKET}${S3_PREFIX}${DEST_FILE}"
  rm -rf $SRC_FILE
done
