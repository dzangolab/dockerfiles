# dzangolab/docker-secrets

A scratch image containing a POSIX-compliant shell script for adding support for Docker secrets to other Docker images.

It does so by expanding environment variables ending in `_FILE` defined as docker secrets.

## Purpose

Most docker images support environment variables for passing credentials at runtime. However, it is considered bad practice to pass on credentials as environment variables in plaintext. Docker provides a convenient solution with [Docker secrets](https://docs.docker.com/compose/how-tos/use-secrets/).

Unfortunately, to take advantage of Docker secrets, a Docker image must explicitly provide support for them. The `dzangolab/docker-secrets` image can be used to add support for Docker secrets to images that don't.

A common convention is to define, for every sensitive environment variable, another environment variable named with the original variable name suffixed with `_FILE`. The value of this `_FILE` env var is the path to a Docker secret file (`/run/secrets/<secret name>`). This secret file contains the secret value.

For example, the `postgres` Docker image supports both the `POSTGRES_PASSWORD` environment variable (which takes as value the postgres root password in plaintext), or the `POSTGRES_PASSWORD_FILE` environment variable. The value of this variable is expected to be the path to a docker secret (eg `/run/secrets/my-secret-postgres-password`). The docker secret is a file that contains the value of the original `POSTGRES_PASSWORD` variable.

Since the `postgres` image natively supports Docker secrets, there is no need to use `dzangolab/docker-secrets` in this case. But for Docker images that do not support Docker secrets natively, `dzangolab/docker-secrets` provides a way to replicate the `postgres` image's approach.

## How it works

The `dzangolab/docker-secrets` image provides a script named `expand_secrets.sh`. Sourcing it and calling its `expand_secrets` function will parse every exported environment variable whose name ends with `_FILE`, and for each one:

* skip it (with a warning, if `DZANGOLAB_DOCKER_SECRETS_DEBUG` is set) unless its value is a path under `/run/secrets/` — this guards against treating an unrelated `*_FILE` variable as a secret reference
* skip it (with an error to stderr) if the corresponding non-suffixed variable is already set, to avoid silently overriding an explicitly provided value
* otherwise, if the path exists, read its content and create a new environment variable where:
  * the name is the `_FILE` env var without the `_FILE` suffix (eg `DATABASE_PASSWORD_FILE` becomes `DATABASE_PASSWORD`)
  * the value is the secret value (ie the content of the file located at the path that was the value of the `_FILE` env var)
  * the original `_FILE` env var is unset

This script can be `COPY`'ed to your Docker image in a multi-stage build.

## Requirements

The `expand_secrets.sh` script is written in POSIX `sh` and has no bash-specific dependencies. It works as-is with `bash`, `dash` (the default `/bin/sh` on Debian/Ubuntu) and BusyBox `sh` (the default `/bin/sh` on Alpine) — no extra package install is required.

The script does shell out to `env` and `sed` to enumerate `_FILE`-suffixed environment variables; these are present on virtually every base image.

## Usage

Note: This image is not meant to be used on its own, but as a stage in a multi-stage docker build.

Let's assume you want to add support for Docker secrets to your app. Your original Dockerfile declares a start script at the path `/path/to/my/apps/start.sh`.

### Image entrypoint

Modify your application's startup script to source the `docker-secrets` image's `expand_secrets.sh` script and call `expand_secrets`.

Here we assume the script will be available in the same folder as your startup script. Adjust the path as required.

```sh
#!/bin/sh

# Source the script
. expand_secrets.sh

# Run the `expand_secrets` function defined in the script
expand_secrets

# Your app's original start command(s)
```

### Dockerfile

Modify your app's Dockerfile as follows:

* Include the `dzangolab/docker-secrets` image as a `secrets` build stage
* `COPY` the `expand_secrets.sh` script from the `secrets` stage

The `expand_secrets.sh` script must be `COPY`'d to a path in your image that is consistent with the path used in your image's startup script. This is typically your image's `WORKDIR`.

```Dockerfile
# Include `dzangolab/docker-secrets` as the `secrets` build stage
FROM dzangolab/docker-secrets:latest AS secrets

# Your original base image
FROM ...

# Image workdir
# WORKDIR /path/to/workdir

# Copy `expand_secrets.sh` from the `dzangolab/docker-secrets` image
COPY --from=secrets /expand_secrets.sh /path/to/workdir/expand_secrets.sh

# Rest of your Dockerfile
```

Build your Docker image and push it to the Docker registry of your choice.

### Docker Compose

In your `docker-compose.yml` file, use your image as you would use the original image, but replace the original environment variables (eg `DATABASE_PASSWORD`) with the suffixed env vars (`DATABASE_PASSWORD_FILE`), pointing at a Docker secret.

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

Set the `DZANGOLAB_DOCKER_SECRETS_DEBUG` environment variable to any non-empty value on the service to log which `_FILE` variables were skipped, expanded, or pointed at a missing path. Check the service's logs.

## Testing

`test/Dockerfile` builds the image and runs the same set of checks (happy path, the `/run/secrets/`-prefix restriction, the already-set-variable guard, a missing secret file, and debug output) under three shells: `bash` (`test/run_tests.sh`), and `dash` and BusyBox `sh` (`test/run_tests_posix.sh`), to guard against bash-specific syntax creeping back in. Run it locally with:

```bash
docker build -f test/Dockerfile -t docker-secrets-test .
```

The build fails if any assertion fails.
