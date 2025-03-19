#!/bin/bash -eux

source /expand_secrets.sh

if [ -z "${DATABASE_URL:-}" ]; then
  DATABASE_URL=mysql://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}
  export DATABASE_URL
fi

bash /entrypoint.sh
