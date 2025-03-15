#!/usr/bin/env bash

set -e

expand_secret() {
  file_var="$1"
  suffix="_FILE"

  var=${file_var/%$suffix}

  if [ "${!var:-}" ]; then
    echo >&2 "error: $var is already set. $file_var will be ignored"
  else
    eval val=\$$file_var;
    export "$var"="$val"
    unset "$file_var"
    eval val=\$$var;
  fi
}

expand_secrets() {
  for file_secret in $(printenv | cut -f1 -d"=" | grep _FILE$)
  do
    expand_secret $file_secret
  done
}

expand_secrets
