FROM snipe/snipe-it:v5.1.5
LABEL maintainer Dzango Technologies <info@dzango.com>

COPY start.sh /

RUN chmod +x /start.sh

WORKDIR /var/www/html

CMD ["/start.sh"]
