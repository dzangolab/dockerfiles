#!/bin/bash

if [ -n "${APP_KEY_FILE}" ]; then
  export APP_KEY=$(cat $APP_KEY_FILE)
fi

if [ -n "$MAIL_ENV_PASSWORD_FILE}" ]; then
  export MAIL_ENV_PASSWORD=$(cat $MAIL_ENV_PASSWORD_FILE)
fi

if [ -n "${MYSQL_PASSWORD_FILE}" ]; then
  export MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi

/startup.sh
