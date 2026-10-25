#!/bin/bash -eu

. /expand_secrets.sh

expand_secrets

urlencode() {
  php -r 'echo rawurlencode($argv[1]);' "$1"
}

# If DATABASE_URL is not set, construct it from the DATABASE_* components
if [ -z "${DATABASE_URL:-}" ]; then
  : "${DATABASE_HOST:?DATABASE_HOST or DATABASE_URL must be set}"
  : "${DATABASE_PASSWORD:?DATABASE_PASSWORD or DATABASE_URL must be set}"

  DATABASE_URL="mysql://$(urlencode "${DATABASE_USER:-kimai}"):$(urlencode "$DATABASE_PASSWORD")@${DATABASE_HOST}:${DATABASE_PORT:-3306}/${DATABASE_NAME:-kimai}?charset=utf8mb4"
  export DATABASE_URL
fi

# If MAILER_URL is not set, construct it from the MAILER_* components, or
# disable sending mail when MAILER_HOST is not set either
if [ -z "${MAILER_URL:-}" ]; then
  if [ -z "${MAILER_HOST:-}" ]; then
    MAILER_URL="null://null"
  else
    credentials=""
    if [ -n "${MAILER_USER:-}" ]; then
      credentials="$(urlencode "$MAILER_USER")"
      if [ -n "${MAILER_PASSWORD:-}" ]; then
        credentials="${credentials}:$(urlencode "$MAILER_PASSWORD")"
      fi
      credentials="${credentials}@"
    fi

    MAILER_URL="${MAILER_SCHEME:-smtp}://${credentials}${MAILER_HOST}${MAILER_PORT:+:${MAILER_PORT}}"
  fi
  export MAILER_URL
fi

exec /entrypoint.sh "$@"
