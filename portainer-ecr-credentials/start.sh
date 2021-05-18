#!/bin/sh

if [ -n "${AWS_SECRET_ACCESS_KEY_FILE}" ]; then
  export AWS_SECRET_ACCESS_KEY=$(cat $AWS_SECRET_ACCESS_KEY_FILE)
fi

if [ -n "${PORTAINER_PASSWORD_FILE}" ]; then
  export PORTAINER_PASSWORD=$(cat $PORTAINER_PASSWORD_FILE)
fi

npm start
