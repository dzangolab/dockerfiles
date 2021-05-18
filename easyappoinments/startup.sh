#!/bin/sh

sed -i "s/__BASE_URL__/${BASE_URL}/" /var/www/html/config.php

sed -i "s/__LANGUAGE__/${LANGUAGE}/" /var/www/html/config.php

sed -i "s/__DEBUG_MODE__/${DEBUG_MODE}/" /var/www/html/config.php

sed -i "s/__DB_HOST__/${DB_HOST}/" /var/www/html/config.php

sed -i "s/__DB_NAME__/${DB_NAME}/" /var/www/html/config.php

sed -i "s/__DB_USERNAME__/${DB_USERNAME}/" /var/www/html/config.php

sed -i "s/__DB_PASSWORD__/${DB_PASSWORD}/" /var/www/html/config.php

sed -i "s/__GOOGLE_SYNC_FEATURE__/${GOOGLE_SYNC_FEATURE}/" /var/www/html/config.php

sed -i "s/__GOOGLE_PRODUCT_NAME__/${GOOGLE_PRODUCT_NAME}/" /var/www/html/config.php

sed -i "s/__GOOGLE_CLIENT_ID__/${GOOGLE_CLIENT_ID}/" /var/www/html/config.php

sed -i "s/__GOOGLE_CLIENT_SECRET__/${GOOGLE_CLIENT_SECRET}/" /var/www/html/config.php

sed -i "s/__GOOGLE_API_KEY__/${GOOGLE_API_KEY}/" /var/www/html/config.php

docker-php-entrypoint apache2-foreground