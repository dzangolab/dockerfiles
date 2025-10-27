#!/usr/bin/env bash

get_aws_distro() {
  if [ -z $(uname -a | grep x86) ]; then
    echo "x86_64"
  else
    echo "aarch64"
  fi
}

get_aws_distro
