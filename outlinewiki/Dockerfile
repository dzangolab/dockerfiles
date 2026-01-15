FROM dzangolab/docker-secrets:0.9 AS secrets

FROM outlinewiki/outline:1.2.0-3

LABEL maintainer="Dzango Technologies Limited <info@dzangolab.com>"
LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A customer Docker image for the Open-source [OutlineWiki](https://getoutline.com/) team knowledge base with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/outlinewiki"
LABEL org.opencontainers.image.licenses="Business Source License 1.1"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/outlinewiki"
LABEL org.opencontainers.image.title="OutlineWiki"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="1.2.0-3"

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

USER root
ADD start.sh ./start.sh
RUN chmod +x ./start.sh \
    && chown nodejs ./start.sh

USER nodejs

CMD ["/usr/bin/env", "bash", "start.sh"]
