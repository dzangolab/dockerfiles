#!/bin/bash -eux

source /expand_secrets.sh

PG_DATABASE_URL=postgres://${PG_DATABASE_USER}:${PG_DATABASE_PASSWORD}@${PG_DATABASE_HOST}:5432/default
export DATABASE_URL

bash /app/entrypoint.sh