#!/usr/bin/env bash

set -eo pipefail

echo "Starting backup at $(date)"

if [ -z "${S3_BUCKET}" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "${DATABASES}" ]; then
  echo "You need to set the POSTGRES_DATABASES environment variable."
  exit 1
fi

if [ -z "${DATABASE_HOST}" ]; then
  echo "You need to set the DATABASE_HOST environment variable."
  exit 1
fi

if [ -z "${DATABASE_PORT}" ]; then
  DATABASE_PORT=3306
fi

if [ -z "${DATABASE_USER}" ]; then
  echo "You need to set the DATABASE_USER environment variable."
  exit 1
fi

if [ -z "${DATABASE_PASSWORD}" ]; then
  echo "You need to set the DATABASE_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ -z "${DATABASE_VERSION}" ]; then
  DATABASE_VERSION=""
else
  DATABASE_VERSION=".${DATABASE_VERSION}"
fi

if [ -z "${S3_ENDPOINT}" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
if [ "${S3_IAMROLE}" != "true" ]; then
  if [ -z "${S3_ACCESS_KEY_ID}" ]; then
    echo "You need to set the S3_ACCESS_KEY_ID environment variable."
    exit 1
  fi

  if [ -z "${S3_SECRET_ACCESS_KEY}" ]; then
    echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
    exit 1
  fi
else
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_REGION
fi

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

DATABASE_HOST_OPTIONS="-h $DATABASE_HOST -P $DATABASE_PORT -u$DATABASE_USER -p$DATABASE_PASSWORD"
DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")

mysqldump --version

if [ "${DATABASES}" = "ALL" ]; then
  DB_LIST=`mysql $DATABASE_HOST_OPTIONS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys|innodb)"`
else 
  DB_LIST = "${DATABASES//,/ }"
fi

for DB in $DB_LIST; do
  SRC_FILE=dump.sql.gz
  DEST_FILE=${DB}/$(date +"%Y")/$(date +"%m")/${DB}${DATABASE_VERSION}.$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz

  echo "Creating dump of ${DB} database from ${DATABASE_HOST}..."
  if ! mysqldump $DATABASE_HOST_OPTIONS $MYSQL_DUMP_OPTIONS "$DB" | gzip > "$SRC_FILE"; then
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

  echo "Database backup uploaded successfully"
  echo "Uploaded to s3://${S3_BUCKET}${S3_PREFIX}${DEST_FILE}"
  rm -rf $SRC_FILE
done
