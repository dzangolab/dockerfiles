FROM scratch AS secrets

COPY expand_secrets.sh /expand_secrets.sh

FROM bash:5 AS test

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests.sh /run_tests.sh

RUN chmod +x /run_tests.sh && /run_tests.sh
