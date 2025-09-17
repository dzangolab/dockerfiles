#!/bin/bash -eu

. /expand_secrets.sh

expand_secrets

# If NC_DB is not set, construct it from individual components
if [ -z "${NC_DB:-}" ]; then
  # URL encode the password if it's provided in plain text
  if [ -n "${DATABASE_PASSWORD:-}" ]; then
    # Function to URL encode the password
    urlencode() {
      node -p "encodeURIComponent('${1//\'/\\\'}')"
    }

    encoded_password=$(urlencode "$DATABASE_PASSWORD")

    if [ -n "${DATABASE_PORT:-}" ]; then
      DATABASE_PORT=":${DATABASE_PORT}"
    fi

    NC_DB="pg://${DATABASE_HOST}${DATABASE_PORT}?u=${DATABASE_USER}&p=${encoded_password}&d=${DATABASE_NAME}"
  fi

  export NC_DB
fi

bash /usr/src/appEntry/start.sh
