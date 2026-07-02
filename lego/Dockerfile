ARG DOCKER_SECRETS_VERSION=1.1.2
ARG LEGO_VERSION=v4.22.2

FROM dzangolab/docker-secrets:${DOCKER_SECRETS_VERSION} AS secrets

FROM goacme/lego:${LEGO_VERSION}

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A custom Docker image for lego ACME client with added support for Docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/lego"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/lego"
LABEL org.opencontainers.image.title="Dzangolab/lego"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="${LEGO_VERSION}"

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
