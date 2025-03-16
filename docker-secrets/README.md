# dzangolab/docker-secrets

A scratch image containing a bash script for adding support for Docker secrets to other Docker images. 

It does so by expanding environment variables ending in `_FILE` defined as docker secrets.

## Purpose

Most docker images support environment variables for passing credentials at runtime. However, it is considered bad practice to pass on credentials as environment variables in plaintext. Docker provides a convenient solution with [Docker secrets](https://docs.docker.com/compose/how-tos/use-secrets/). 

Unfortunately, to take advantage of Docker secrets, a Docker image must explicitly provide support for them. The `dzangolab/docker-secrets` image can be used to add support for Docker secrets to images that don't.

The convention seems to be that for every sensitive environment variable, another environment variable with the suffix `_FILE` will be defined. The value of this `_FILE` env var is the path to a Docker secret file (`/run/secrets/<secret name>`). This secret file contains the secret value.

For example, the `postgres` Docker image supports both the `POSTGRES_PASSWORD` environment variable (which takes as value the postgres root password in plaintext), or the `POSTGRES_PASSWORD_FILE` environment variable, which is expected to point to a docker secret (eg `/run/secrets/my-secret-postgres-password`). 

Since the `postgres` image natively supports Docker secrets, there is no need to use the `dzangolab/docker-secrets` in this case. But for Docker images that do not support Docker secrets natively, the `dzangolab/docker-secrets` provides a way to replicate the `postgres` image's approach.

## How it works

The `dzangolab/docker-secrets` provides a `expand_secrets.sh` script that will parse all environment variables ending with `_FILE`, check that its value points to an existing file, and if true, create an environment variable where:

* the name will be the `_FILE` env var without the `_FILE` suffix (so `DATABASE_PASSWORD_FILE` becomes `DATABASE_PASSWORD`)
* the value will be the secret value (ie the content of the file located at the path that is the value of the `_FILE` env var.)

This script can be COPY'ed to your Docker image in a multi-stage build.

## Usage

Note: This image is not meant to be used on its own, but as a stage in a multi-stage docker build.

Let's assume you want to add support for Docker secrets to the `amazing-app:latest` Docker image that does not support Docker secrets natively. (This is a dummy image name that only serves as an example).

### Image entrypoint

First, figure out that image's entrypoint. This is typically the value of the last `CMD` or `ENTRYPOINT` instructions in the image's Dockerfile. Let's assume that in this example the entrypoint is a script name `entrypoint.sh`.

Create a bash script with a different name, say `start.sh`. The script should:

* Run `expand_secrets.sh`
* [Optional] Run any other process on other environment variables 
* Run the original entrypoint script

```bash
#!/bin/bash -eu

# start.sh
source expand_secrets.sh

bash entrypoint.sh
```

### Dockerfile

* Create a new Dockerfile.
* Start your multi-stage build with the `dzangolab/docker-secrets` image.
* In the next stage, use the original image.
* Copy the `expanding_secrets.sh` script from `dzangolab/docker-secrets` to your image.
* Copy your startup script and make it executable.
* Declare it as your image's entrypoint.

```Dockerfile
FROM dzangolab/docker-secrets:0.6 as secrets

FROM amazing-app:latest 

COPY --from=secrets /expand_secrets.sh expand_secrets.sh

COPY ./start.sh start.sh

RUN chmod +x start.sh

CMD [start.sh]
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
