FROM snipe/snipe-it:v5.1.4
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY env_secrets_expand.sh /
COPY start.sh /

RUN chmod +x /start.sh /env_secrets_expand.sh

WORKDIR /var/www/html

CMD ["/start.sh"]
