FROM snipe/snipe-it:v5.1.4
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY env_secrets_expand.sh /var/www/html/

RUN chmod +x start.sh

CMD ["/start.sh"]
