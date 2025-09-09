FROM dzangolab/docker-secrets:0.9 AS secrets

FROM alpine:3.16
LABEL maintainer="Dzango Technologies Limited <info@dzangolab.com>"
HEALTHCHECK CMD curl --fail http://localhost:18080 || exit 1

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh

RUN apk --no-cache add \
        binutils \
        curl \
    && apk add --no-cache \
        mysql-client \
        mariadb-connector-c \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
        glibc-*.apk \
    && curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz | zcat > /usr/local/bin/go-cron \
    && chmod u+x /usr/local/bin/go-cron \
    && apk --no-cache del \
        binutils \
    && rm -rf /var/cache/apk/*

ADD run.sh run.sh
ADD backup.sh backup.sh

ENV DATABASES=ALL
# ENCRYPTION_PASSWORD=
ENV EXTRA_OPTIONS="--quote-names --quick --add-drop-table --add-locks --allow-keywords --disable-keys --extended-insert --single-transaction --create-options --comments --net_buffer_length=16384"
# ENV DATABASE_HOST=
ENV DATABASE_PORT=3306
# ENV DATABASE_USER=
# ENV DATABASE_PASSWORD=
# ENV S3_ACCESS_KEY_ID=
# ENV S3_BUCKET=
# ENV S3_ENDPOINT=
# ENV S3_FILENAME=
# ENV S3_PREFIX=
ENV S3_REGION=us-west-1
ENV S3_S3V4=no
# ENV S3_SECRET_ACCESS_KEY=
# ENV S3_SUFFIX=
ENV MULTI_FILES=no
ENV SCHEDULE=@daily

CMD ["sh", "run.sh"]
