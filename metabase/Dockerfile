FROM metabase/metabase:v0.65.2.1
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
