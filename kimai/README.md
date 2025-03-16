# dzangolab/kimai

A custom Docker image for the Open-source time tracker [Kimai](https://www.kimai.org/) app with added support for docker secrets.

## Base image

This image is based on the [kimai/kimai2:apache-2.31.0](https://hub.docker.com/layers/kimai/kimai2/apache-2.31.0/images/sha256-5602f80946c9adf19d04b76b54b71befb6b8d0c535d05239faa54803689e92bd) image.

## Environment variables

The image supports all the [original environment variables](https://www.kimai.org/documentation/docker.html#environment-variables) from the base image, with the addition of:

* `DATABASE_HOST` - The database host
* `DATABASE_NAME` - The database name (default: `kimai`)
* `DATABASE_PASSWORD` - The database password
* `DATABASE_PORT` - The database port (default: `3306`)
* `DATABASE_USER` - The database user
* `ENV_SECRETS_DEBUG` - A boolean flag for debugging the secret expansion process

These are used to construct the `DATABASE_URL` environment variable unless that variable is present.

## Docker secrets

This image makes use of the `dzangolab/docker-secrets` image.

Any environment variable can be defined via a [Docker secret](https://docs.docker.com/engine/swarm/secrets/) by declaring an environment variable with the `_FILE` suffix. The value of the `_FILE`-suffixed env var should be the path to the Docker secret.

It is recommended that all environment variables representing sensitive values should be declared with a `_FILE` suffix. These include:

* `APP_SECRET`
* `DATABASE_PASSWORD`
* `DATABASE_URL` (see below)
* `ADMINPASS`

## Database credentials

You should avoid declaring the full `DATABASE_URL` as an environment variable, as it contains the unencrypted database password.

Note that the `DATABASE_URL` environment variable is still supported, and if defined, it will be used in priority.

Other options available to you, in order of precedence:

### `DATABASE_URL_FILE`

If the `DATABASE_URL_FILE` environment variable is defined, as the path to a Docker secret, the value of that secret will be set as the value of the `DATABASE_URL` environment variable at runtime.

### `DATABASE_PASSWORD_FILE` 

If the `DATABASE_PASSWORD_FILE` environment variable is defined, as the path to a Docker secret, the value of that secret will be set as the value of the `DATABASE_PASSWORD` environment variable. 

This will be used, in conjunction with the other `DATABASE_*` environment variables, to define the `DATABASE_URL` environment variable at runtime.

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
