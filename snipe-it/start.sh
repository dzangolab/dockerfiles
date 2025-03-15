#!/bin/bash

if [ -n "${APP_KEY_FILE}" ]; then
  APP_KEY=$(cat "$APP_KEY_FILE")
  export APP_KEY
fi

if [ -n "${MAIL_ENV_PASSWORD_FILE}" ]; then
  MAIL_ENV_PASSWORD=$(cat "$MAIL_ENV_PASSWORD_FILE")
  export MAIL_ENV_PASSWORD
fi

if [ -n "${MYSQL_PASSWORD_FILE}" ]; then
  MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
  export MYSQL_PASSWORD
fi

/startup.sh
