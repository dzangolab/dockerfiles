#!/usr/bin/env sh

set -eu

env_secret_debug()
{
  if [ ! -z "${ENV_SECRETS_DEBUG:-}" ]; then
    echo -e "\033[1m$@\033[0m"
  fi
}

expand_secret() {
  file_var=$1
  eval "secret_path=\$$file_var"  # Get the value of the _FILE variable

  suffix="_FILE"
  var=${file_var%$suffix}  # Remove the _FILE suffix to get the target variable name

  current_value=$(eval "echo \${$var:-}")
  if [ -n "$current_value" ]; then
    echo >&2 "error: $var is already set. $file_var will be ignored"
  else
    if [ -f "$secret_path" ]; then
      secret_value=$(cat "${secret_path}" | tr -d '\n')  # Read file and remove newlines
      export -- "${var}"="${secret_value}"
      unset "$file_var"
      env_secret_debug "Expanded variable: $var=${secret_value}"
    else
      env_secret_debug "Path to secret $secret_path does not exist!"
    fi
  fi
}

expand_secrets() {
  for file_var in $(printenv | cut -f1 -d"=" | grep _FILE$)
  do
    expand_secret "$file_var"
  done

  if [ ! -z "${ENV_SECRETS_DEBUG:-}" ]; then
      echo -e "\n\033[1mExpanded environment variables\033[0m"
      printenv
  fi
}

expand_secrets