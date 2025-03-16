#!/bin/bash -eux

/expand_secrets.sh

if [ ! -n "${DATABASE_URL}" ]; then
  DATABASE_URL=mysl://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}
  export DATABASE_URL
fi

/entrypoint.sh
