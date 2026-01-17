#!/usr/env/bin bash

set -e

. /expand_secrets.sh

# expand_secrets

if [ ! -z "${DZANGOLAB_DOCKER_SECRETS_DEBUG:-}" ]; then
    echo -e "\033[1m$@\033[0m"
fi

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ -z "${SCHEDULE}" ]; then
  /usr/bin/env bash backup.sh
else
  exec go-cron -s "$SCHEDULE" -- /usr/bin/env bash backup.sh
fi
