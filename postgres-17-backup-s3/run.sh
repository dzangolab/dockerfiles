#!/bin/sh

set -e

. /expand_secrets.sh

expand_secrets

if [ "${S3_S3V4:-}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ -z "${SCHEDULE:-}" ]; then
  sh backup.sh
else
  exec go-cron -s "$SCHEDULE" -- sh backup.sh
fi
