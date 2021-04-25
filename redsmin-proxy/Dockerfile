FROM redsmin/proxy
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY env_secrets_expand.sh /
COPY start.sh /

RUN chmod +x /start.sh /env_secrets_expand.sh

CMD ["/start.sh"]
