FROM dzangolab/docker-secrets:0.9 AS secrets

FROM nocodb/nocodb:0.264.6

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A customer Docker image for the Open-source [NocoDB](https://nocodb.com/) no-code database with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/nocodb"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/nocodb"
LABEL org.opencontainers.image.title="NocoDB"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="0.264.6"

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

CMD [ "/start.sh" ]
