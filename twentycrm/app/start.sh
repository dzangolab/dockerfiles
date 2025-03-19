#!/bin/bash -eux

source /expand_secrets.sh

if [ -z "${DATABASE_URL:-}" ]; then
    ENCODED_PASSWORD=$(echo -n "$PG_DATABASE_PASSWORD" | jq -sRr @uri)
    PG_DATABASE_URL="postgres://${PG_DATABASE_USER}:${ENCODED_PASSWORD}@${PG_DATABASE_HOST}:5432/default"
    export DATABASE_URL="$PG_DATABASE_URL"
fi

bash /app/entrypoint.sh