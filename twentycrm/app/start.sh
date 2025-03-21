#!/bin/sh -eux

source /expand_secrets.sh

echo $DATABASE_NAME
PG_DATABASE_URL="postgres://${PG_DATABASE_USER}:${PG_DATABASE_PASSWORD}@${PG_DATABASE_HOST}:5432/${DATABASE_NAME}"
export PG_DATABASE_URL

sh /app/entrypoint.sh $@