#!/bin/sh -eux

source /expand_secrets.sh

PG_DATABASE_URL="postgres://${PG_DATABASE_USER}:${PG_DATABASE_PASSWORD}@${PG_DATABASE_HOST}:5432/${PG_DATABASE_NAME}"
export PG_DATABASE_URL

yarn database:migrate:prod
yarn command:prod upgrade

sh /app/entrypoint.sh "$@"
