ARG DOCKER_SECRETS_VERSION=1.1.4
ARG PHP_VERSION=8.3.36

FROM dzangolab/docker-secrets:${DOCKER_SECRETS_VERSION} AS secrets

FROM php:${PHP_VERSION}-fpm

ARG PHP_VERSION
ARG IMAGICK_VERSION=3.8.1
ARG MEMORY_LIMIT=-1
ARG POST_MAX_SIZE=10M
ARG TIMEZONE=Asia/Hong_Kong
ARG UPLOAD_MAX_FILESIZE=10M

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A custom Docker image running PHP-FPM and nginx in a single container, with added support for Docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/php-fpm-nginx"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/php-fpm-nginx"
LABEL org.opencontainers.image.title="Dzangolab/php-fpm-nginx"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="${PHP_VERSION}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    coreutils \
    cron \
    git \
    gnupg \
    libcap2-bin \
    libcurl4-gnutls-dev \
    libfreetype6-dev \
    libgeoip-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng-dev \
    libxml2-dev \
    libxslt1-dev \
    libxslt1.1 \
    libzip-dev \
    locales \
    nginx \
    openssh-client \
    unzip \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" \
    calendar \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    shmop \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    zip \
 && pecl install "imagick-${IMAGICK_VERSION}" \
 && docker-php-ext-enable imagick \
 && rm -rf /tmp/pear \
 && { \
      echo "date.timezone=${TIMEZONE}"; \
      echo "memory_limit=${MEMORY_LIMIT}"; \
      echo "upload_max_filesize=${UPLOAD_MAX_FILESIZE}"; \
      echo "post_max_size=${POST_MAX_SIZE}"; \
      echo "display_errors=0"; \
      echo "log_errors=1"; \
    } > /usr/local/etc/php/conf.d/zz-docker-args.ini \
 && usermod -u 1001 www-data \
 && setcap cap_net_bind_service=+ep /usr/sbin/nginx \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 && touch /run/nginx.pid /var/log/cron.log \
 && chown -R www-data:www-data /run/nginx.pid /var/lib/nginx /var/www

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

COPY ./etc/nginx/default.conf /etc/nginx/sites-available/default
COPY ./etc/php-fpm.d/zz-www.conf /usr/local/etc/php-fpm.d/zz-www.conf
COPY ./etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --chown=www-data:www-data ./www/ /var/www/html/web/

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /var/www/html

EXPOSE 80 443

ENV PATH="/var/www/.composer/vendor/bin:${PATH}"

CMD ["/start.sh"]
