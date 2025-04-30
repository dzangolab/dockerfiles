#!/bin/bash -eux

# Source secrets if the file exists
if [ -f /expand_secrets.sh ]; then
  source /expand_secrets.sh
fi

# If DATABASE_URL is not set, construct it from individual components
if [ -z "${DATABASE_URL:-}" ]; then
  # URL encode the password if it's provided in plain text
  if [ -n "${DATABASE_PASSWORD:-}" ]; then
    # Function to URL encode the password
    urlencode() {
      local string="${1}"
      local strlen=${#string}
      local encoded=""
      local pos c o

      for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
          [-_.~a-zA-Z0-9] ) o="${c}" ;;
          * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
      done
      echo "${encoded}"
    }

    encoded_password=$(urlencode "$DATABASE_PASSWORD")
    DATABASE_URL="mysql://${DATABASE_USER}:${encoded_password}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
  else
    # If no password is provided, construct URL without password
    DATABASE_URL="mysql://${DATABASE_USER}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
  fi
  export DATABASE_URL
fi

bash /entrypoint.sh