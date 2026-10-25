FROM scratch AS secrets

COPY expand_secrets.sh /expand_secrets.sh

FROM bash:5.3.20 AS test-bash

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests.sh /run_tests.sh

RUN bash /run_tests.sh

# Debian's /bin/sh is dash
FROM debian:trixie-20261020-slim AS test-dash

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests.sh /run_tests.sh

RUN dash /run_tests.sh

FROM alpine:3.24.3 AS test-busybox-sh

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests.sh /run_tests.sh

RUN /bin/sh /run_tests.sh

# Depends on every test stage so that BuildKit doesn't skip any of them
FROM scratch AS test

COPY --from=test-bash /expand_secrets.sh /expand_secrets.sh
COPY --from=test-dash /expand_secrets.sh /expand_secrets.sh
COPY --from=test-busybox-sh /expand_secrets.sh /expand_secrets.sh
