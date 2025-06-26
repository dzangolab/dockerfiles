#!/bin/bash -eux

cd $1
docker buildx build --platform linux/amd64 -t dzangolab/$1:$2 --push .
