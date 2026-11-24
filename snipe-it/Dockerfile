FROM snipe/snipe-it:v8.8.3
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY start.sh /

RUN chmod +x /start.sh

WORKDIR /var/www/html

CMD ["/start.sh"]
