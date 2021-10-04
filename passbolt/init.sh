#!/bin/bash

if [ -n "${DATASOURCES_DEFAULT_PASSWORD_FILE}" ]; then
  DATASOURCES_DEFAULT_PASSWORD=$(cat "$DATASOURCES_DEFAULT_PASSWORD_FILE")
  export DATASOURCES_DEFAULT_PASSWORD
fi

if [ -n "${EMAIL_TRANSPORT_DEFAULT_PASSWORD_FILE}" ]; then
  EMAIL_TRANSPORT_DEFAULT_PASSWORD=$(cat "$EMAIL_TRANSPORT_DEFAULT_PASSWORD_FILE")
  export EMAIL_TRANSPORT_DEFAULT_PASSWORD
fi

su -m -s /bin/sh \
  -c "/usr/share/php/passbolt/bin/cake \
      passbolt register_user \
      -u $1 \
      -f $2 \
      -l $3 \
      -r admin" \
  www-data
