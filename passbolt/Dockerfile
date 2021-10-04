FROM passbolt/passbolt:latest-ce
LABEL maintainer="Dzango Technologies Limited <info@dzangolab.com>"

COPY start.sh /
COPY init.sh ./init.sh

RUN chmod +x /start.sh \
  && chmod +x ./init.sh

CMD ["/start.sh"]
