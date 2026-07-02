#!/bin/sh
set -eu

. /expand_secrets.sh

expand_secrets

exec "$@"
