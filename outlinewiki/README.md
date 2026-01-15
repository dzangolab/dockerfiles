# Outline Wiki

A docker secrets-enabled image for the open-source [Outline Wiki](https://www.getoutline.com/) platform.

## Usage

Use the `dzangolab/outlinewiki:1.2.0-0` image as a drop-in replacement for the original `outlinewiki/outline:1.2.0` image.

### Docker secrets

Define any sensitive environment variable using a variable of the same name suffixed with `_FILE`. 

Define a Docker secret for each such variable:

```sh
echo "your_secret_key" | docker secret create secret-key -
```

Your `docker-compose.yml` file should look like this:

```yaml
secrets:
  database-url:
    external: true
  secret-key: 
    external: true
  utils-secret:
    external: true

services:
  outline:
    image: dzangolab/outlinewiki:1.2.0-0
    env:
      ...
      DATABASE_URL_FILE=/run/secrets/database-url
      SECRET_KEY_FILE=/run/secrets/secret-key
      UTILS_SECRET_FILE=/run/secrets/utils-secret
      ...
    secrets:
      - database-url
      - secret-key
      - utils-secret

## Testing locally

To test this image locally, run the `docker-compose.yml` supplied in the code:

```bash
docker compose up
```

And open this url in your browser: `https://outline.test`

The following services will be created:

| Service | URL |
|---------|-----|
| Outline | https://outline.test |
| Adminer | http://localhost:8080 |
| Postgres | http://postgres:5432 |
| Redis    | http://redis:6379 |
| Https portal | https://outline.test |

Https portal is provided by way of the [`steveltn/https-portal`](https://hub.docker.com/r/steveltn/https-portal) image.
