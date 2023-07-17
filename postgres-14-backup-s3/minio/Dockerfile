ARG TAG=latest
FROM minio/minio:$TAG

COPY --from=docker.io/minio/mc:latest /usr/bin/mc /usr/bin/mc
RUN mkdir /buckets
RUN minio server /buckets --address ":9001" --console-address ":9000" & \
    server_pid=$!; \
    until mc alias set local http://localhost:9001 minioadmin minioadmin; do \
        sleep 1; \
    done; \
    mc mb local/backups; \
    mc anonymous set upload local/backups; \
    kill $server_pid
