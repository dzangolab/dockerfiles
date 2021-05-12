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

# If the Oauth DB files are not present copy the vendor files over to the db migrations
if [ ! -f "/var/www/html/database/migrations/*create_oauth*" ]
then
  cp -ax /var/www/html/vendor/laravel/passport/database/migrations/* /var/www/html/database/migrations/
fi

if [ "${SESSION_DRIVER}" = "database" ]; then
  cp -ax /var/www/html/vendor/laravel/framework/src/Illuminate/Session/Console/stubs/database.stub /var/www/html/database/migrations/2021_05_06_000001_create_sessions_table.php
fi

chmod -R 777 /var/www/html/storage

php artisan migrate --force
php artisan config:clear
php artisan config:cache

/startup.sh
