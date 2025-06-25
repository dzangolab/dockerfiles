FROM dzangolab/docker-secrets:0.6 AS secrets

FROM outlinewiki/outline:0.60.3

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A customer Docker image outline app with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/outline"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/outline"
LABEL org.opencontainers.image.title="Outline"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version=""

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

USER root
COPY ./start.sh /start.sh
RUN chmod +x /start.sh

CMD ["bash", "/start.sh"]
