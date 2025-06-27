#!/bin/bash -eux
set -e

. /expand_secrets.sh

# export_secret() {
#   local var_name="$1"
#   local file_var="${var_name}_FILE"
#   local file_path
  
#   file_path="${!file_var:-}"
  
#   if [ -n "$file_path" ]; then
#     if [ -f "$file_path" ]; then
#       export "${var_name}=$(cat "$file_path")"
#     else
#       echo "Warning: Secret file $file_path not found" >&2
#     fi
#   fi
# }

# # List of possible secrets Outline might use
# export_secret "AWS_ACCESS_KEY_ID"
# export_secret "AWS_SECRET_ACCESS_KEY"
# export_secret "DATABASE_URL"
# export_secret "DATABASE_PASSWORD"
# export_secret "GOOGLE_CLIENT_ID"
# export_secret "GOOGLE_CLIENT_SECRET"
# export_secret "SECRET_KEY"
# export_secret "SMTP_PASSWORD"
# export_secret "UTILS_SECRET"
# export_secret "OIDC_CLIENT_SECRET"
# export_secret "SLACK_APP_ID"
# export_secret "SLACK_APP_SECRET"
# export_secret "SLACK_VERIFICATION_TOKEN"

# If DATABASE_URL is not set, construct it from individual components
# if [ -z "${DATABASE_URL:-}" ]; then
#   # URL encode the password if it's provided in plain text
#   if [ -n "${DATABASE_PASSWORD:-}" ]; then
#     # Function to URL encode the password
#     urlencode() {
#       local string="${1}"
#       local strlen=${#string}
#       local encoded=""
#       local pos c o

#       while [ -n "$string" ]; do
#         c=${string%"${string#?}"}  # Get first character
#         case "$c" in
#           [-_.~a-zA-Z0-9]) encoded="${encoded}${c}" ;;
#           *) 
#             hex=$(printf '%%%02x' "'$c")
#             encoded="${encoded}${hex}"
#             ;;
#         esac
#         string=${string#?}  # Remove first character
#       done
#       echo "${encoded}"
#     }

#     encoded_password=$(urlencode "$DATABASE_PASSWORD")
#     DATABASE_URL="postgres://${DATABASE_USER}:${encoded_password}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
#   fi
#   export DATABASE_URL
# fi
echo "=== DEBUG: Current Environment Variables ==="
env | grep -E 'DATABASE|SSL|NODE_ENV'
echo ""

echo "=== DEBUG: Database Configuration ==="
if [ -f "/opt/outline/server/config/database.json" ]; then
  cat /opt/outline/server/config/database.json
else
  echo "database.json not found!"
fi
echo ""

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