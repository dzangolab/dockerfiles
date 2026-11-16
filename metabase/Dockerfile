FROM metabase/metabase:v0.65.4.3
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
