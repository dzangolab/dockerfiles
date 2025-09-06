# dzangolab/docker-secrets

A scratch image containing a bash script for adding support for Docker secrets to other Docker images. 

It does so by expanding environment variables ending in `_FILE` defined as docker secrets.

## Purpose

Most docker images support environment variables for passing credentials at runtime. However, it is considered bad practice to pass on credentials as environment variables in plaintext. Docker provides a convenient solution with [Docker secrets](https://docs.docker.com/compose/how-tos/use-secrets/). 

Unfortunately, to take advantage of Docker secrets, a Docker image must explicitly provide support for them. The `dzangolab/docker-secrets` image can be used to add support for Docker secrets to images that don't.

A common convention is to define, for every sensitive environment variable, another environment variable named with the original variable name suffixed with `_FILE`. The value of this `_FILE` env var is the path to a Docker secret file (`/run/secrets/<secret name>`). This secret file contains the secret value.

For example, the `postgres` Docker image supports both the `POSTGRES_PASSWORD` environment variable (which takes as value the postgres root password in plaintext), or the `POSTGRES_PASSWORD_FILE` environment variable. The value of this variable is expected to be the path to a docker secret (eg `/run/secrets/my-secret-postgres-password`). The docker secret is a file that contains the value of the original `POSTGRES_PASSWORD` variable.

Since the `postgres` image natively supports Docker secrets, there is no need to use the `dzangolab/docker-secrets` in this case. But for Docker images that do not support Docker secrets natively, the `dzangolab/docker-secrets` provides a way to replicate the `postgres` image's approach.

## How it works

The `dzangolab/docker-secrets` provides a script named `expand_secrets.sh` that will parse all environment variables ending with `_FILE`, and for each such variable found, check that its value points to an existing file, and if true, create an environment variable where:

* the environment variable's name will be the `_FILE` env var without the `_FILE` suffix (eg `DATABASE_PASSWORD_FILE` becomes `DATABASE_PASSWORD`)
* the environment variable's value will be the secret value (ie the content of the file located at the path that is the value of the `_FILE` env var.)

This script can be COPY'ed to your Docker image in a multi-stage build.

## Requirements

The `expand_secrets.sh` script makes use of the `${!...}` bashism (indirect variable expansion) which is not availablke in other POSIX_compliant shells. If your image does not include `bash` (eg Alpine linux, Ubuntu) you will need to install it.

For example on  Alpine Linux, add the following line to your Dockerfile:

```
RUN apk add --no-cache bash
```

## Usage

Note: This image is not meant to be used on its own, but as a stage in a multi-stage docker build.

Let's assume you want to add support for Docker secrets to your app. Your original dockerfile declares a start script at the path `/path/to.my/apps/start.sh`. 

### Image entrypoint

Modify you application' startup script to include the `docker-secrets` image's `expand_secrets` script.

Here we assume the script will be available in the same folder as your startup script. Adjust the path as required.

```bash
#!/bin/bash

# Source the script
. expand_secrets.sh

# Run the `expand_secrets` command defined in the script
expand_secrets 

// Your app's original start command(s)
```

### Dockerfile

Modify your app's Dockerfile as follows:

* Include the `dzangolab/docker-secrets` image as a `secrets` target build
* COPY the `expand_secrets.sh` script from the `secrets` target

The `expand_secrets.sh` script must be COPY'd to a path in your image that is consistent with the path used in your image's startup script. This is typically your image's `WORKDIR`.

```Dockerfile
# Include `dzangolab.docker-secrets` as a the `secrets` target build
FROM dzangolab/docker-secrets:latest as secrets

# Your original base image 
FROM ... 

# Image workdir
# WORKDIR /path/to /workdir

# Copy `expand-secrets.sh` from `dzangolab/docker-secrets` image
COPY --from=secrets /expand_secrets.sh /path/to/workdir/expand_secrets.sh

# Rest of your Dockerfile

```

Build your Docker image and push it to the Docker registry of your choice.

### Docker compose

In your docker-compose.yml file, use your image as you would use the original image, but replace the original environment variables (eg `DATABASE_PASSWORD`) with the suffixed env vars (`DATABASE_PASSWORD_FILE`).

```yaml
secrets:
  my-password:
    external: true

services:
  app:
    image: my/amazing-app:1.0
    environment:
      - DATABASE_PASSWORD_FILE=/run/secrets/my-password
    secrets:
      - my-password
```

Create the docker secret:

```bash
printf "my very secret password" | docker secret create my-password -
```

Run docker compose:

```bash
docker compose up -d
```

## Debugging

Set the `ENV_SECRETS_DEBUG` environment variable to `true` on the service. Check the service's logs.
