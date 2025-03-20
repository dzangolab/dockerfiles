#!/bin/bash -eux

source /expand_secrets.sh

# ENCODED_PASSWORD=$(echo -n "$PG_DATABASE_PASSWORD" | jq -sRr @uri)
PG_DATABASE_URL="postgres://${PG_DATABASE_USER}:${PG_DATABASE_PASSWORD}@${PG_DATABASE_HOST}:5432/default"
export PG_DATABASE_URL

bash /app/entrypoint.sh