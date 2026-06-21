FROM scratch AS secrets

COPY expand_secrets.sh /expand_secrets.sh

FROM bash:5 AS test-bash

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests.sh /run_tests.sh

RUN chmod +x /run_tests.sh && /run_tests.sh

FROM debian:bookworm-slim AS test-dash

RUN apt-get update && apt-get install -y --no-install-recommends dash && rm -rf /var/lib/apt/lists/*

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests_posix.sh /run_tests_posix.sh

RUN chmod +x /run_tests_posix.sh && dash /run_tests_posix.sh

FROM alpine:3 AS test-busybox-sh

COPY --from=secrets /expand_secrets.sh /expand_secrets.sh
COPY test/run_tests_posix.sh /run_tests_posix.sh

RUN chmod +x /run_tests_posix.sh && /bin/sh /run_tests_posix.sh

FROM scratch AS test

COPY --from=test-bash /expand_secrets.sh /expand_secrets.sh
COPY --from=test-dash /expand_secrets.sh /expand_secrets.sh
COPY --from=test-busybox-sh /expand_secrets.sh /expand_secrets.sh
