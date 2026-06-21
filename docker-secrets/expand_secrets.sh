#!/bin/sh

set -eu

debug()
{
  if [ -n "${DZANGOLAB_DOCKER_SECRETS_DEBUG:-}" ]; then
    printf '\033[1m%s\033[0m\n' "$*"
  fi
}

expand_secret() {
  file_var=$1

  eval "secret_path=\${$file_var:-}"

  var=${file_var%_FILE}

  case "$secret_path" in
    /run/secrets/*) ;;
    *)
      debug "Skipping $file_var: path '$secret_path' is not under /run/secrets/"
      return 1
      ;;
  esac

  eval "current=\${$var:-}"
  if [ -n "$current" ]; then
    echo "error: $var is already set. $file_var will be ignored" >&2
    return 1
  fi

  if [ -f "$secret_path" ]; then
    secret_value=$(cat "$secret_path")
    eval "$var=\$secret_value"
    export "$var"
    unset "$file_var"
    debug "Expanded variable: $var"
  else
    debug "Path to secret $secret_path does not exist!"
  fi
}

expand_secrets() {
  for file_var in $(env | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p'); do
    case "$file_var" in
      *_FILE)
        expand_secret "$file_var" || true
        ;;
    esac
  done
}
