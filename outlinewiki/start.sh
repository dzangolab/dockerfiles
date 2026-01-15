#!/usr/bin/env bash

set -eu
set -x

. /expand_secrets.sh

expand_secrets

node build/server/index.js
