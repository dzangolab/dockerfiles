FROM dzangolab/docker-secrets:0.2 AS secrets
LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

FROM kimai/kimai2:apache-2.31.0

CMD [ "/start.sh" ]

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

COPY /start.sh /start.sh
RUN chmod +x /start.sh

ENV DATABASE_HOST=
ENV DATABASE_NAME=kimai
ENV DATABASE_PASSWORD=
ENV DATABASE_PORT=3309
ENV DATABASE_USER=
