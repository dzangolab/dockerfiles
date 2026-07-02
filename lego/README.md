# lego

A custom Docker image for the [lego](https://go-acme.github.io/lego/) ACME client with added support for Docker secrets. Based on [`goacme/lego:v5.2.2`](https://hub.docker.com/r/goacme/lego).

## What this image adds

Built on top of [`goacme/lego`](https://hub.docker.com/r/goacme/lego), this image adds:

- **Docker secrets support** — any environment variable ending in `_FILE` is automatically expanded from its file contents at startup (via `dzangolab/docker-secrets`), enabling secure credential injection in Docker Swarm.

## Usage

Docker:

```sh
docker run \
  -e CLOUDFLARE_DNS_API_TOKEN=your-token \
  -v lego-data:/root/.lego \
  dzangolab/lego \
  --email you@example.com \
  --dns cloudflare \
  --domains example.com \
  run
```

With Docker secrets (`_FILE` convention):

```sh
docker run \
  -e CLOUDFLARE_DNS_API_TOKEN_FILE=/run/secrets/cf_token \
  -v lego-data:/root/.lego \
  dzangolab/lego \
  --email you@example.com \
  --dns cloudflare \
  --domains example.com \
  run
```

Docker Compose / Swarm:

```yaml
services:
  lego:
    image: dzangolab/lego
    command: >
      --email you@example.com
      --dns cloudflare
      --domains example.com
      renew
    environment:
      CLOUDFLARE_DNS_API_TOKEN_FILE: /run/secrets/cloudflare_dns_api_token
    secrets:
      - cloudflare_dns_api_token
    volumes:
      - lego-data:/root/.lego

secrets:
  cloudflare_dns_api_token:
    external: true
```

## Environment variables

All environment variables supported by the upstream `goacme/lego` image are passed through unchanged. Additionally, any variable ending in `_FILE` will have its contents read from the specified file path and exported as the variable without the `_FILE` suffix. For example:

- `CLOUDFLARE_DNS_API_TOKEN_FILE` → reads file, exports as `CLOUDFLARE_DNS_API_TOKEN`

## Build arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `LEGO_VERSION` | `v5.2.2` | Upstream lego image tag |
| `DOCKER_SECRETS_VERSION` | `1.1.2` | Version of `dzangolab/docker-secrets` to pull from |

## Related

- [Ansible role: docker_lego](../../ansible/roles/docker_lego/README.md) — deploys this image as a Docker Swarm stack with Cloudflare DNS, automated renewal, and Traefik integration
- [goacme/lego documentation](https://go-acme.github.io/lego/)
- [dzangolab/docker-secrets](https://github.com/dzangolab/docker-secrets)
