FROM lovasoa/wbo:latest

COPY start.sh /start.sh

USER 0:0
RUN chmod +x /start.sh

USER 1000:1000
CMD ["/start.sh"]
