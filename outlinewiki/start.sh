#!/usr/bin/env bash

set -eu

. /expand_secrets.sh

expand_secrets

node build/server/index.js
