#!/bin/sh

if [ -n "${AUTH_SECRET_KEY_FILE}" ]; then
  AUTH_SECRET_KEY=$(cat "$AUTH_SECRET_KEY_FILE")
  export AUTH_SECRET_KEY
fi

/usr/local/bin/node server/server.js
