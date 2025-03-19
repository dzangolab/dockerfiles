FROM dzangolab/docker-secrets:0.6 AS secrets

FROM twentycrm/twenty:v0.44.4

LABEL org.opencontainers.image.authors="info@dzangolab.com"
LABEL org.opencontainers.image.description="A customer Docker image for the Open-source [twentycrm](https://twenty.com/) app with added support for docker secrets."
LABEL org.opencontainers.image.documentation="https://github.com/dzangolab/dockerfiles/tree/main/twentycrm"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/dzangolab/dockerfiles/tree/main/twentycrm"
LABEL org.opencontainers.image.title="TwentyCRM"
LABEL org.opencontainers.image.url="https://dzango.com"
LABEL org.opencontainers.image.vendor="Dzango Technologies"
LABEL org.opencontainers.image.version="local"

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

USER root
COPY ./app/start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD [ "/app/start.sh" ]

# ENV PG_DATABASE_USER = twentycrm
# ENV PG_DATABASE_PASSWORD = 
# ENV PG_DATABASE_HOST = twentycrm
# ENV PG_DATABASE_PORT = 5432

# ENV SERVER_URL = http://localhost=3000
# ENV SIGN_IN_PREFILLED = false

# # APP_SECRET_FILE=MlkSY+KId5LpRRKrt9c+R9QjddVgPgHkO8o4QOogHHE=

# ENV STORAGE_TYPE = local

# STORAGE_S3_REGION=eu-west3
# STORAGE_S3_NAME=my-bucket
# STORAGE_S3_ENDPOINT=