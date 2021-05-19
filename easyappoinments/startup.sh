#!/bin/sh

set -e

if [ -n "${DB_PASSWORD_FILE}" ]; then
  DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
  export AWS_SECRET_ACCESS_KEY
fi

if [ -n "${GOOGLE_CLIENT_SECRET_FILE}" ]; then
  GOOGLE_CLIENT_SECRET=$(cat "$GOOGLE_CLIENT_SECRET_FILE")
  export PORTAINER_PASSWORD
fi

if [ -n "${GOOGLE_API_KEY_FILE}" ]; then
  GOOGLE_API_KEY=$(cat "$GOOGLE_API_KEY_FILE")
  export GOOGLE_API_KEY
fi

sed -i "s;__BASE_URL__;${BASE_URL};" /var/www/html/config.php

if [ -n "${LANGUAGE}" ]; then
  sed -i "s/__LANGUAGE__/${LANGUAGE}/" /var/www/html/config.php
else
  sed -i "s/__LANGUAGE__/english/" /var/www/html/config.php
fi

if [ ${DEBUG_MODE} = 'TRUE' ]; then
  sed -i "s/__DEBUG_MODE__/TRUE/" /var/www/html/config.php
else
  sed -i "s/__DEBUG_MODE__/FALSE/" /var/www/html/config.php
fi

sed -i "s/__DB_HOST__/${DB_HOST}/" /var/www/html/config.php

sed -i "s/__DB_NAME__/${DB_NAME}/" /var/www/html/config.php

sed -i "s/__DB_USERNAME__/${DB_USERNAME}/" /var/www/html/config.php

sed -i "s/__DB_PASSWORD__/${DB_PASSWORD}/" /var/www/html/config.php

if [ ${GOOGLE_SYNC_FEATURE} = 'TRUE' ]; then
  sed -i "s/__GOOGLE_SYNC_FEATURE__/TRUE/" /var/www/html/config.php
else
  sed -i "s/__GOOGLE_SYNC_FEATURE__/FALSE/" /var/www/html/config.php
fi

sed -i "s/__GOOGLE_PRODUCT_NAME__/${GOOGLE_PRODUCT_NAME}/" /var/www/html/config.php

sed -i "s/__GOOGLE_CLIENT_ID__/${GOOGLE_CLIENT_ID}/" /var/www/html/config.php

sed -i "s/__GOOGLE_CLIENT_SECRET__/${GOOGLE_CLIENT_SECRET}/" /var/www/html/config.php

sed -i "s/__GOOGLE_API_KEY__/${GOOGLE_API_KEY}/" /var/www/html/config.php

docker-php-entrypoint apache2-foreground
