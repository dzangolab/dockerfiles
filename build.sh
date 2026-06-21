#!/bin/bash -eux

if ! docker buildx inspect multiplatform &>/dev/null; then
  docker buildx create --name multiplatform --driver docker-container --bootstrap
fi

docker buildx use multiplatform

cd $1
docker buildx build --platform linux/amd64,linux/arm64 -t dzangolab/$1:$2 --push .
cd ..

./update-dockerhub-description.sh $1
