#! /bin/sh

set -e

if [ -n "${MYSQL_PASSWORD_FILE}" ]; then
  MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
  export MYSQL_PASSWORD
fi

if [ -n "${S3_ACCESS_KEY_ID_FILE}" ]; then
  S3_ACCESS_KEY_ID=$(cat "$S3_ACCESS_KEY_ID_FILE")
  export S3_ACCESS_KEY_ID
fi

if [ -n "${S3_SECRET_ACCESS_KEY_FILE}" ]; then
  S3_SECRET_ACCESS_KEY=$(cat "$S3_SECRET_ACCESS_KEY_FILE")
  export S3_SECRET_ACCESS_KEY
fi

if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then
  echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
fi

if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then
  echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
fi

if [ "${S3_BUCKET}" == "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${MYSQL_HOST}" == "**None**" ]; then
  echo "You need to set the MYSQL_HOST environment variable."
  exit 1
fi

if [ "${MYSQL_USER}" == "**None**" ]; then
  echo "You need to set the MYSQL_USER environment variable."
  exit 1
fi

if [ "${MYSQL_PASSWORD}" == "**None**" ]; then
  echo "You need to set the MYSQL_PASSWORD environment variable or link to a container named MYSQL."
  exit 1
fi

if [ "${S3_IAMROLE}" != "true" ]; then
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_REGION
fi

MYSQL_HOST_OPTS="-h $MYSQL_HOST -P $MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD"

fetch_s3 () {
  SRC_FILE=$1
  DEST=/tmp

  if [ "${S3_ENDPOINT}" == "**None**" ]; then
    AWS_ARGS=""
  else
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  if [ "${S3_PREFIX}" == "**None**" ]; then
    SRC="s3://$S3_BUCKET/${SRC_FILE}"
  else
    SRC="s3://$S3_BUCKET/$S3_PREFIX/$SRC_FILE"
  fi

  echo "Downloading ${SRC_FILE} to S3..."

  cat $SRC | aws $AWS_ARGS s3 cp - $DEST

  if [ $? != 0 ]; then
    >&2 echo "Error downloading ${SRC_FILE} from S3"
  fi
}

mysql $MYSQL_HOST_OPTS < $DEST

echo "Restore completed"
