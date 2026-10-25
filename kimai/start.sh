#!/bin/bash -eu

. /expand_secrets.sh

expand_secrets

# If DATABASE_URL is not set, construct it from the DATABASE_* components
if [ -z "${DATABASE_URL:-}" ]; then
  : "${DATABASE_HOST:?DATABASE_HOST or DATABASE_URL must be set}"
  : "${DATABASE_PASSWORD:?DATABASE_PASSWORD or DATABASE_URL must be set}"

  urlencode() {
    php -r 'echo rawurlencode($argv[1]);' "$1"
  }

  DATABASE_URL="mysql://$(urlencode "${DATABASE_USER:-kimai}"):$(urlencode "$DATABASE_PASSWORD")@${DATABASE_HOST}:${DATABASE_PORT:-3306}/${DATABASE_NAME:-kimai}?charset=utf8mb4"
  export DATABASE_URL
fi

exec /entrypoint.sh "$@"
