#!/bin/bash -eux
set -e

# Expand all environment variables that might contain secret references
. /expand_secrets.sh

export_secret() {
  local var_name="$1"
  local file_var="${var_name}_FILE"
  local file_path
  
  # Safe indirect variable expansion
  file_path="${!file_var:-}"
  
  if [ -n "$file_path" ]; then
    if [ -f "$file_path" ]; then
      export "${var_name}=$(cat "$file_path")"
    else
      echo "Warning: Secret file $file_path not found" >&2
    fi
  fi
}

# List of possible secrets Outline might use
export_secret "AWS_ACCESS_KEY_ID"
export_secret "AWS_SECRET_ACCESS_KEY"
export_secret "DB_PASSWORD"
export_secret "GOOGLE_CLIENT_ID"
export_secret "GOOGLE_CLIENT_SECRET"
export_secret "SECRET_KEY"
export_secret "SMTP_PASSWORD"
export_secret "UTILS_SECRET"
export_secret "OIDC_CLIENT_SECRET"
export_secret "SLACK_APP_ID"
export_secret "SLACK_APP_SECRET"
export_secret "SLACK_VERIFICATION_TOKEN"

# Add any other secret exports Outline might need
export_secret "AZURE_CLIENT_SECRET"
export_secret "GITHUB_CLIENT_SECRET"
export_secret "MICROSOFT_CLIENT_SECRET"

exec yarn start