ARG DOCKER_SECRETS_VERSION=1.1.4
ARG KIMAI_VERSION=2.70.2

FROM dzangolab/docker-secrets:${DOCKER_SECRETS_VERSION} AS secrets

FROM kimai/kimai2:${KIMAI_VERSION}

ARG KIMAI_VERSION

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A customer Docker image for the Open-source time tracker [Kimai](https://www.kimai.org/) app with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/kimai"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/kimai"
LABEL org.opencontainers.image.title="Kimai"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="${KIMAI_VERSION}"

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

CMD [ "/start.sh" ]

ENV MAILER_URL=
