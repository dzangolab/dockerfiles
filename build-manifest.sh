#!/bin/bash -eux

cd $1
docker buildx build \
  --platform linux/amd64 \
  -f Dockerfile.amd64 \
  -t dzangolab/$1:$2-amd64 \
  --load \
  .

docker buildx build \
  --platform linux/arm64 \
  -f Dockerfile.arm64 \
  -t dzangolab/$1:$2-arm64 \
  --load \
  .

docker push dzangolab/$1:$2-amd64
docker push dzangolab/$1:$2-arm64

docker manifest create dzangolab/$1:$2 \
  --amend dzangolab/$1:$2-amd64 \
  --amend dzangolab/$1:$2-arm64

docker manifest annotate dzangolab/$1:$2 dzangolab/$1:$2-amd64 --os linux --arch amd64
docker manifest annotate dzangolab/$1:$2 dzangolab/$1:$2-arm64 --os linux --arch arm64

docker manifest push dzangolab/$1:$2
