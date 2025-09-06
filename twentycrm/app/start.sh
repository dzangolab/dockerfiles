#!/bin/sh -eux

source /expand_secrets.sh

# If DATABASE_URL is not set, construct it from individual components
if [ -z "${PG_DATABASE_URL:-}" ]; then
  # URL encode the password if it's provided in plain text
  if [ -n "${PG_DATABASE_PASSWORD:-}" ]; then
    # Function to URL encode the password
    urlencode() {
      node -p "encodeURIComponent('${1//\'/\\\'}')"
    }

    encoded_password=$(urlencode "$PG_DATABASE_PASSWORD")

    PG_DATABASE_URL="postgres://${PG_DATABASE_USER}:${encoded_password}@${PG_DATABASE_HOST}:5432/${PG_DATABASE_NAME}"
  fi
  export PG_DATABASE_URL
fi

sh /app/entrypoint.sh "$@"
