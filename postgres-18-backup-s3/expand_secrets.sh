#!/usr/bin/env bash

set -eu

debug()
{
  if [ ! -z "${DZANGOLAB_DOCKER_SECRETS_DEBUG:-}" ]; then
    echo -e "\033[1m$@\033[0m"
  fi
}

expand_secret() {
  file_var=$1
  debug echo "Expanding secret: ${file_var} (${!file_var})"
  secret_path="${!file_var}"
  debug echo "Secret path: ${secret_path}"

  suffix="_FILE"
  var=${file_var/%$suffix}
  debug echo "Environment variable: ${var}"

  if [ "${!var:-}" ]; then
    echo >&2 "error: $var is already set. $file_var will be ignored"
  else
    if [ -f "$secret_path" ]; then
      secret_value=$(cat "${secret_path}")
      export -- "${var}"="${secret_value}"    
      unset "$file_var"
      debug echo "Expanded variable: $var=${!var}"
    else
      debug echo "Path to secret $secret_path does not exist!"
    fi
  fi
}

expand_secrets() {
  for file_var in $(printenv | cut -f1 -d"=" | grep _FILE$)
  do
    debug echo "Expanding variable: ${file_var} (${!file_var})"
    expand_secret ${file_var}
  done

  if [ ! -z "${DZANGOLAB_DOCKER_SECRETS_DEBUG:-}" ]; then
    echo -e "\n\033[1mExpanded environment variables\033[0m"
    printenv
  fi
}
