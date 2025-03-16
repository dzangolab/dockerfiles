# dzangolab/kimai

A customer Dockerimage for the Open-source time tracker [Kimai](https://www.kimai.org/) app with added support for docker secrets.

## Base image

This image is based on the [kimai/kimai2:apache-2.31.0](https://hub.docker.com/layers/kimai/kimai2/apache-2.31.0/images/sha256-5602f80946c9adf19d04b76b54b71befb6b8d0c535d05239faa54803689e92bd) image.

## Environment variables

The image supports all the [original environment variables](https://www.kimai.org/documentation/docker.html#environment-variables) from the base image, with the addition of:

* `DATABASE_HOST` - The database host
* `DATABASE_NAME` - The database name (default: `kimai`)
* `DATABASE_PASSWORD` - The database password
* `DATABASE_PORT` - The database port (default: `3309`)
* `DATABASE_USER` - The database user

These are used to construct the `DATABASE_URL` environment variable unless that variable is present.

## Docker secrets

Any environment variable can be defined via a [Docker secret](https://docs.docker.com/engine/swarm/secrets/) by declaring an environment variable with the `_FILE` suffix. The value of the `_FILE`-suffixed env var should be the path to the Docker secret.

It is recommended that all environment variables representing sensitive values should be declared with a `_FILE` suffix. Thiese include:

* `APP_SECRET`
* `DATABASE_PASSWORD`
* `DATABASE_URL` (see below)
* `ADMINPASS`

### Example

Assuming you have 

* defined a `kimai-password` Docker secret as per below:

```bash
docker secret create kimai-password "my secret password"
```

* and passed the `DATABASE_PASSWORD_FILE` to the `kimai` service

```
services:
  kimai:
    image: dzangolab/kimai:latest
    env:
      - DATABASE_PASSWORD_FILE=/run/secrets/kimai-password
      ...
```

Then the `DATABASE_PASSWORD` environment variable will be created at runtime and will take the value of the `kimai-password` secret.

## Database credentials

You should avoid declaring the full `DATABASE_URL` as an environment variable, as it contains the unencrypted database password.

Note that if the `DATABASE_URL` environment variable is still supported, and if defined, it will be used in priority.

Other option available to you, in order of precedence:

### `DATABASE_URL_FILE`

If the `DATABASE_URL_FILE` environment variable is defined, as the path to a Docker secret, the value of that secret will be set as the value of the `DATABASE_URL` environment variable at runtime.

### `DATABASE_PASSWORD_FILE` 

If the `DATABASE_PASSWORD_FILE` environment variable is deinfed, as the path to a Docker secret, the value of that secret will be set as the value of the `DATABASE_PASSWORD` environment variable. 

This will be used, in conjunction with the other `DATABASE_` environment variables, to define the `DATABASE_URL` environment variable at runtime.
