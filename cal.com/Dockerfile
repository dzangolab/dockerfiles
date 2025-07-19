FROM dzangolab/docker-secrets:0.6.sh AS secrets

FROM calcom/cal.com:v5.4.9

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A custom Docker image for the Open-source [cal.com](https://cal.com/) app with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/cal.com"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/cal.com"
LABEL org.opencontainers.image.title="Cal.com"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="5.4.9"

WORKDIR /calcom

COPY --from=secrets /expand_secrets.sh /calcom/scripts/expand_secrets.sh

USER root
COPY ./pre-start.sh /calcom/scripts/pre-start.sh
RUN chmod +x /calcom/scripts/pre-start.sh

CMD ["/calcom/scripts/pre-start.sh"]
