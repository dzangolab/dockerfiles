# dzangolab/php-fpm-nginx

A Docker image running [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) and [nginx](https://nginx.org/) in a single container, with added support for Docker secrets.

It is intended as a base image for PHP applications.

## Base image

This image is based on the official [php:8.3.36-fpm](https://hub.docker.com/_/php) image (Debian).

## What's included

* nginx, listening on port 80, serving `/var/www/html/web`, and passing `*.php` requests to PHP-FPM on `127.0.0.1:9000`
* PHP extensions, in addition to those built into the base image: `calendar`, `exif`, `gd` (with FreeType and JPEG), `gettext`, `gmp`, `imagick`, `intl`, `mysqli`, `opcache`, `pcntl`, `pdo_mysql`, `shmop`, `sockets`, `sysvmsg`, `sysvsem`, `sysvshm`, `xsl`, `zip`
* Tools: `cron`, `git`, `openssh-client`, `unzip`, `build-essential`
* OPcache enabled (see `etc/php/conf.d/opcache.ini`)

PHP-FPM workers run as `www-data`, with UID `1001`.

## Build arguments

| Argument                 | Default          | Description                                  |
| ------------------------ | ---------------- | -------------------------------------------- |
| `PHP_VERSION`            | `8.3.36`         | Tag of the `php:<version>-fpm` base image    |
| `DOCKER_SECRETS_VERSION` | `1.1.4`          | Version of `dzangolab/docker-secrets`        |
| `IMAGICK_VERSION`        | `3.8.1`          | PECL `imagick` version                       |
| `TIMEZONE`               | `Asia/Hong_Kong` | PHP `date.timezone`                          |
| `MEMORY_LIMIT`           | `-1`             | PHP `memory_limit`                           |
| `UPLOAD_MAX_FILESIZE`    | `10M`            | PHP `upload_max_filesize`                    |
| `POST_MAX_SIZE`          | `10M`            | PHP `post_max_size`                          |

`display_errors` is off and `log_errors` is on. PHP errors and nginx access/error logs are sent to the container's output (`docker logs`).

## Docker secrets

This image makes use of the `dzangolab/docker-secrets` image.

Any environment variable can be defined via a [Docker secret](https://docs.docker.com/engine/swarm/secrets/) by declaring an environment variable with the `_FILE` suffix. The value of the `_FILE`-suffixed env var should be the path to the Docker secret, under `/run/secrets/`.

For example, `DATABASE_PASSWORD_FILE=/run/secrets/db-password` sets `DATABASE_PASSWORD` to the content of that secret at startup.

Environment variables, including expanded secrets, are available to PHP via `getenv()` and `$_SERVER` (the FPM pool sets `clear_env = no`).

Set `DZANGOLAB_DOCKER_SECRETS_DEBUG` to any non-empty value to log which secrets were expanded.

## Usage

### As a base image

```Dockerfile
FROM dzangolab/php-fpm-nginx:8.3.36

COPY --chown=www-data:www-data . /var/www/html
```

nginx serves `/var/www/html/web`, so your app's public entry point must be in a `web/` folder. To change the nginx config, copy your own server block over `/etc/nginx/sites-available/default`. To add PHP settings, add `.ini` files to `/usr/local/etc/php/conf.d/`.

### Running commands

With no command, the container starts PHP-FPM and nginx. If either one exits, the container exits with a non-zero code, so a restart policy can restart it.

Any other command is run instead of the web stack, after secrets are expanded:

```bash
docker run --rm dzangolab/php-fpm-nginx:8.3.36 php -v
```

## Migrating from `dzangolab/docker-php-nginx`

This image replaces `dzangolab/docker-php-nginx`. Differences:

* The image uses `CMD ["/start.sh"]` instead of `ENTRYPOINT ["/bin/sh"]`. Commands passed to `docker run` are executed directly, not as arguments to `sh`.
* The sample `index.php` prints `OK` instead of `phpinfo()`.
* PHP-FPM pool settings live in `/usr/local/etc/php-fpm.d/zz-www.conf` instead of replacing `www.conf`. Downstream images that overwrite `www.conf` should override `zz-www.conf` instead.
* The container exits if PHP-FPM or nginx dies. In the old image, the container kept running if PHP-FPM died.
* nginx returns 403 for dotfiles (except `/.well-known/`), 404 for missing `.php` files, and no longer forces the `HTTPS` FastCGI param to `off`.

## Related

- Github: [dzangolab/dockerfiles/php-fpm-nginx](https://github.com/dzangolab/dockerfiles/tree/main/php-fpm-nginx)
