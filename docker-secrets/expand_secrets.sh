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
  secret_path="${!file_var}"

  suffix="_FILE"
  var=${file_var/%$suffix}

  if [[ "$secret_path" != /run/secrets/* ]]; then
    debug "Skipping $file_var: path '$secret_path' is not under /run/secrets/"
    return 1
  fi

  if [ "${!var:-}" ]; then
    echo >&2 "error: $var is already set. $file_var will be ignored"
    return 1
  fi

  if [ -f "$secret_path" ]; then
    secret_value=$(cat "${secret_path}")
    export -- "${var}"="${secret_value}"
    unset "$file_var"
    debug "Expanded variable: $var"
  else
    debug "Path to secret $secret_path does not exist!"
  fi
}

expand_secrets() {
  while IFS= read -r file_var; do
    [[ "$file_var" == *_FILE ]] || continue
    expand_secret "$file_var" || true
  done < <(compgen -e)
}
