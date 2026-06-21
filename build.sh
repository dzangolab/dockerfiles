#!/bin/bash -eux

if ! docker buildx inspect multiplatform &>/dev/null; then
  docker buildx create --name multiplatform --driver docker-container --bootstrap
fi

docker buildx use multiplatform

cd $1

build_args=()
if [ -n "${DOCKER_SECRETS_VERSION:-}" ]; then
  build_args+=(--build-arg "DOCKER_SECRETS_VERSION=${DOCKER_SECRETS_VERSION}")
fi

docker buildx build --platform linux/amd64,linux/arm64 "${build_args[@]}" -t dzangolab/$1:$2 --push .
cd ..

./update-dockerhub-description.sh $1
