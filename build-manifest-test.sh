#!/bin/bash -eux

cd $1

build_args=()
if [ -n "${DOCKER_SECRETS_VERSION:-}" ]; then
  build_args+=(--build-arg "DOCKER_SECRETS_VERSION=${DOCKER_SECRETS_VERSION}")
fi

docker buildx build \
  --platform linux/amd64 \
  -f Dockerfile.amd64 \
  "${build_args[@]}" \
  -t dzangolab/$1:$2-amd64 \
  --load \
  .
