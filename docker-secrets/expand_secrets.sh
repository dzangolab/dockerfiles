#!/usr/bin/env bash

set -eu

env_secret_debug()
{
  if [ ! -z "${ENV_SECRETS_DEBUG:-}" ]; then
    echo -e "\033[1m$@\033[0m"
  fi
}

expand_secret() {
  file_var=$1
  secret_path="${!file_var}"

  suffix="_FILE"
  var=${file_var/%$suffix}

  if [ "${!var:-}" ]; then
    echo >&2 "error: $var is already set. $file_var will be ignored"
  else
    if [ -f "$secret_path" ]; then
      secret_value=$(cat "${secret_path}")
      export -- "${var}"="${secret_value}"    
      unset "$file_var"
      env_secret_debug "Expanded variable: $var=${!var}"
    else
      env_secret_debug "Path to secret $secret_path does not exist!"
    fi
  fi
}

expand_secrets() {
  for file_var in $(printenv | cut -f1 -d"=" | grep _FILE$)
  do
    expand_secret $file_var
  done

  if [ ! -z "${ENV_SECRETS_DEBUG:-}" ]; then
      echo -e "\n\033[1mExpanded environment variables\033[0m"
      printenv
  fi
}

expand_secrets