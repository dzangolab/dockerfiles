FROM dzangolab/docker-secrets:latest AS secrets

FROM kimai/kimai2:apache-2.37.0

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A customer Docker image for the Open-source time tracker [Kimai](https://www.kimai.org/) app with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/kimai"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/kimai"
LABEL org.opencontainers.image.title="Kimai"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="apache-2.37.0-1"

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

CMD [ "/start.sh" ]

ENV DATABASE_HOST=
ENV DATABASE_NAME=kimai
ENV DATABASE_PASSWORD=
ENV DATABASE_PORT=3306
ENV DATABASE_USER=kimai
