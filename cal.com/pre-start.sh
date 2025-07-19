#!/bin/bash -eux

source /calcom/scripts/expand_secrets.sh

# If DATABASE_URL is not set, construct it from individual components
if [ -z "${DATABASE_URL:-}" ]; then
  # URL encode the password if it's provided in plain text
  if [ -n "${DATABASE_PASSWORD:-}" ]; then
    # Function to URL encode the password
    urlencode() {
      node -p "encodeURIComponent('${1//\'/\\\'}')"
    }

    encoded_password=$(urlencode "$DATABASE_PASSWORD")

    DATABASE_URL="postgres://${DATABASE_USER}:${encoded_password}@${DATABASE_HOST}:5432/${DATABASE_NAME}"
    DATABASE_DIRECT_URL=$DATABASE_URL
  fi

  export DATABASE_URL
  export DATABASE_DIRECT_URL
fi

sh /calcom/scripts/start.sh "$@"
