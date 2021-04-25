#!/bin/sh

source /env_secrets_expand.sh

REDSMIN_KEY=$REDSMIN_KEY REDIS_URI=$REDIS_URI REDIS_AUTH=$REDIS_AUTH redsmin
