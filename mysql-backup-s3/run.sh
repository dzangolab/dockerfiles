#! /bin/sh

set -e

if [ -n "${MYSQL_PASSWORD_FILE}" ]; then
  export MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi

if [ -n "${S3_SECRET_ACCESS_KEY_FILE}" ]; then
  export S3_SECRET_ACCESS_KEY=$(cat $S3_SECRET_ACCESS_KEY_FILE)
fi

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi
