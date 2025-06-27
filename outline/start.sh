#!/bin/bash -eux
set -e

. /expand_secrets.sh

if [ -z "${DATABASE_URL:-}" ]; then
  # URL encode the password if it's provided in plain text
  if [ -n "${DATABASE_PASSWORD:-}" ]; then
    # Function to URL encode the password
    urlencode() {
      local string="${1}"
      local strlen=${#string}
      local encoded=""
      local pos c o

      while [ -n "$string" ]; do
        c=${string%"${string#?}"}  # Get first character
        case "$c" in
          [-_.~a-zA-Z0-9]) encoded="${encoded}${c}" ;;
          *) 
            hex=$(printf '%%%02x' "'$c")
            encoded="${encoded}${hex}"
            ;;
        esac
        string=${string#?}  # Remove first character
      done
      echo "${encoded}"
    }

    encoded_password=$(urlencode "$DATABASE_PASSWORD")
    DATABASE_URL="postgres://${DATABASE_USER}:${encoded_password}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
  fi
  export DATABASE_URL
fi

wait_for_db() {
  until nc -z postgres 5432; do
    echo "Waiting for PostgreSQL"
    sleep 2
  done
}

wait_for_db
echo "Running database migrations..."
yarn db:migrate

exec yarn start