FROM php:7.4-apache AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG EASYAPPOINMENT_RELEASE=1.4.1

WORKDIR "/var/www/html"

# Download and extract easyappointments tarball
RUN curl -o easyappointments.tar.gz -fL "https://github.com/alextselegidis/easyappointments/archive/refs/tags/$EASYAPPOINMENT_RELEASE.tar.gz"; \
    tar -xzf easyappointments.tar.gz --strip-components=1 -C /var/www/html/; \
    rm easyappointments.tar.gz; 

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd gettext mysqli pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename composer \
    && composer update

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt update \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build

FROM php:7.4-apache

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR "/var/www/html"

COPY --from=build /var/www/html/build .

RUN rm CHANGELOG.md LICENSE README.md composer.json

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd gettext mysqli pdo_mysql

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

COPY php.ini /usr/local/etc/php/conf.d/99-overrides.ini

COPY config.php  /var/www/html/

RUN a2enmod rewrite

RUN chmod 1777 storage/backups storage/cache storage/logs storage/sessions storage/uploads

VOLUME [ "/var/www/html/storage" ]