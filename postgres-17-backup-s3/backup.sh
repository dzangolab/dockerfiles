#!/bin/bash

set -x
set -eo pipefail

echo "Starting backup at $(date)"

if [ -n "${POSTGRES_PASSWORD_FILE}" ]; then
  POSTGRES_PASSWORD=$(cat "$POSTGRES_PASSWORD_FILE")
  export POSTGRES_PASSWORD
fi

if [ -n "${S3_ACCESS_KEY_ID_FILE}" ]; then
  S3_ACCESS_KEY_ID=$(cat "$S3_ACCESS_KEY_ID_FILE")
  export S3_ACCESS_KEY_ID
fi

if [ -n "${S3_SECRET_ACCESS_KEY_FILE}" ]; then
  S3_SECRET_ACCESS_KEY=$(cat "$S3_SECRET_ACCESS_KEY_FILE")
  export S3_SECRET_ACCESS_KEY
fi

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${POSTGRES_DATABASE}" = "**None**" -a "${POSTGRES_BACKUP_ALL}" != "true" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ -z ${POSTGRES_VERSION+x} ]; then
  POSTGRES_VERSION=""
else
  POSTGRES_VERSION="${POSTGRES_VERSION}/"
fi

if [ "${S3_ENDPOINT}" == "**None**" ]; then
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

if [ -z ${S3_PREFIX+x} ]; then
  S3_PREFIX="/"
else
  S3_PREFIX="/${S3_PREFIX}/"
fi

if [ -z ${S3_SUFFIX+x} ]; then
  S3_SUFFIX=""
else
  S3_SUFFIX="-${S3_SUFFIX}"
fi

if [ "${POSTGRES_BACKUP_ALL}" == "true" ]; then
  DB_LIST=$(psql $POSTGRES_HOST_OPTS -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'default';")

  for DB in $DB_LIST; do
    SRC_FILE=dump.sql.gz
    DEST_FILE=${DB}${S3_SUFFIX}_$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz

    echo "Creating dump of ${DB} database from ${POSTGRES_HOST}..."
    if ! pg_dump $POSTGRES_HOST_OPTS "$DB" | gzip > "$SRC_FILE"; then
      >&2 echo "Error creating dump for database: ${DB}"
      continue
    fi

    if [ "${ENCRYPTION_PASSWORD}" != "**None**" ] && [ -n "${ENCRYPTION_PASSWORD}" ]; then
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
    echo "Uploaded to s3://${S3_BUCKET}${S3_PREFIX}${POSTGRES_VERSION}${DEST_FILE}"
    cat $SRC_FILE | aws $AWS_ARGS s3 cp - "s3://${S3_BUCKET}${S3_PREFIX}${POSTGRES_VERSION}${DEST_FILE}" || exit 2


    echo "SQL backup uploaded successfully"
    rm -rf $SRC_FILE
  done
else
  OIFS="$IFS"
  IFS=','
  for DB in $POSTGRES_DATABASE
  do
    IFS="$OIFS"

    SRC_FILE=dump.sql.gz
    DEST_FILE=${DB}${S3_SUFFIX}_$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz

    echo "Creating dump of ${DB} database from ${POSTGRES_HOST}..."
    pg_dump $POSTGRES_HOST_OPTS $DB | gzip > $SRC_FILE

    if [ "${ENCRYPTION_PASSWORD}" != "**None**" ]; then
      echo "Encrypting ${SRC_FILE}"
      openssl enc -aes-256-cbc -in $SRC_FILE -out ${SRC_FILE}.enc -k $ENCRYPTION_PASSWORD
      if [ $? != 0 ]; then
        >&2 echo "Error encrypting ${SRC_FILE}"
      fi
      rm $SRC_FILE
      SRC_FILE="${SRC_FILE}.enc"
      DEST_FILE="${DEST_FILE}.enc"
    fi

    echo "Uploading dump to $S3_BUCKET"
    cat $SRC_FILE | aws $AWS_ARGS s3 cp - "s3://${S3_BUCKET}${S3_PREFIX}${DEST_FILE}" || exit 2

    echo "SQL backup uploaded successfully"
    rm -rf $SRC_FILE
  done
fi
