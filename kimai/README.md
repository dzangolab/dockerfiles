# dzangolab/kimai

A custom Docker image for the Open-source time tracker [Kimai](https://www.kimai.org/) app with added support for docker secrets.

## Base image

This image is based on the [kimai/kimai2:2.70.2](https://hub.docker.com/layers/kimai/kimai2/2.70.2) image.

## Environment variables

The image supports all the [original environment variables](https://www.kimai.org/documentation/docker.html#environment-variables) from the base image, with the addition of:

* `DATABASE_HOST` - The database host
* `DATABASE_NAME` - The database name (default: `kimai`)
* `DATABASE_PASSWORD` - The database password
* `DATABASE_PORT` - The database port (default: `3306`)
* `DATABASE_USER` - The database user (default: `kimai`)
* `ENV_SECRETS_DEBUG` - A boolean flag for debugging the secret expansion process
* `MAILER_HOST` - The SMTP host
* `MAILER_PASSWORD` - The SMTP password
* `MAILER_PORT` - The SMTP port (default: chosen by Symfony Mailer for the scheme)
* `MAILER_SCHEME` - The mailer scheme, eg. `smtp` or `smtps` (default: `smtp`)
* `MAILER_USER` - The SMTP user

The `DATABASE_*` variables are used to construct the `DATABASE_URL` environment variable, and the `MAILER_*` variables the `MAILER_URL` environment variable, unless that variable is present. See [Database credentials](#database-credentials) and [Mailer credentials](#mailer-credentials).

## Docker secrets

This image makes use of the `dzangolab/docker-secrets` image.

Any environment variable can be defined via a [Docker secret](https://docs.docker.com/engine/swarm/secrets/) by declaring an environment variable with the `_FILE` suffix. The value of the `_FILE`-suffixed env var should be the path to the Docker secret.

It is recommended that all environment variables representing sensitive values should be declared with a `_FILE` suffix. These include:

* `ADMINPASS`
* `APP_SECRET`
* `DATABASE_PASSWORD`
* `DATABASE_URL` (see below)
* `MAILER_PASSWORD`
* `MAILER_URL` (see below)

## Database credentials

You should avoid declaring the full `DATABASE_URL` as an environment variable, as it contains the unencrypted database password.

Note that the `DATABASE_URL` environment variable is still supported, and if defined, it will be used in priority.

Other options available to you, in order of precedence:

### `DATABASE_URL_FILE`

If the `DATABASE_URL_FILE` environment variable is defined, as the path to a Docker secret, the value of that secret will be set as the value of the `DATABASE_URL` environment variable at runtime.

### `DATABASE_PASSWORD_FILE` 

If the `DATABASE_PASSWORD_FILE` environment variable is defined, as the path to a Docker secret, the value of that secret will be set as the value of the `DATABASE_PASSWORD` environment variable. 

This will be used, in conjunction with the other `DATABASE_*` environment variables, to define the `DATABASE_URL` environment variable at runtime.

### Special characters in passwords

When the `DATABASE_URL` is built from `DATABASE_PASSWORD` and `DATABASE_USER`, both values are percent-encoded, so they may contain any character.

If you supply `DATABASE_URL` (or `DATABASE_URL_FILE`) yourself, you must percent-encode the user and password. The following characters break the parsing of the URL, either by Kimai's startup script (which splits the URL on `/`, `:` and `@`) or by Doctrine:

| Character | Encoded |
| --------- | ------- |
| `#`       | `%23`   |
| `%`       | `%25`   |
| `+`       | `%2B`   |
| `/`       | `%2F`   |
| `:`       | `%3A`   |
| `?`       | `%3F`   |
| `@`       | `%40`   |
| `[`       | `%5B`   |
| `]`       | `%5D`   |

A literal `+` is decoded as a space by Kimai's database check but kept as `+` by Doctrine, so it must always be encoded. A literal `%` starts an escape sequence. To be safe, percent-encode every character that is not a letter, a digit, `-`, `.`, `_` or `~`.

## Mailer credentials

Kimai sends mail through [Symfony Mailer](https://symfony.com/doc/6.4/mailer.html), configured by the `MAILER_URL` environment variable.

As with `DATABASE_URL`, you should avoid declaring the full `MAILER_URL` as an environment variable if it contains a password. In order of precedence:

1. `MAILER_URL`, or `MAILER_URL_FILE` as the path to a Docker secret, is used as is.
2. Otherwise, if `MAILER_HOST` is defined, `MAILER_URL` is built as `<MAILER_SCHEME>://<MAILER_USER>:<MAILER_PASSWORD>@<MAILER_HOST>:<MAILER_PORT>`. The user, password and port are optional. Use `MAILER_PASSWORD_FILE` to pass the password as a Docker secret.
3. Otherwise, `MAILER_URL` is set to `null://null`, and Kimai does not send any mail.

When the `MAILER_URL` is built from `MAILER_USER` and `MAILER_PASSWORD`, both values are percent-encoded, so they may contain any character. If you supply `MAILER_URL` yourself, percent-encode the user and password, as described for `DATABASE_URL` [above](#special-characters-in-passwords).

## Usage

### Create Docker secrets

Create a Docker secret for each sensitive credential:

```bash
printf "secret admin password" | docker secret create kimai-adminpass -
printf "secret database password" | docker secret create kimai-password -
```

### Docker compose 

Create a `docker-compose.yml` file as per below:

```yaml
secrets:
  kimai-adminpass:
    file: kimai-adminpass
  kimai-password:
    file: kimai-password

  kimai:
    environment:
      - ADMINMAIL=admin@kimai.local
      - ADMINPASS_FILE=/run/secrets/kimai-adminpass
      - DATABASE_HOST=sqldb
      - DATABASE_PASSWORD_FILE=/run/secrets/kimai-password
      - DATABASE_USER=kimai
      - ENV_SECRETS_DEBUG=1
    image: dzangolab/kimai:local
    ports:
      - 8001:8001
    restart: unless-stopped
    secrets:
      - kimai-adminpass
      - kimai-password
    volumes:
      - data:/opt/kimai/var/data
      - plugins:/opt/kimai/var/plugins
```

Run `docker-compose up -d`

See the sample `docker-compose.yml` file in this repo.
