#!/usr/bin/env bash

if [[ ! -f /usr/libexec/docker/cli-plugins/docker-buildx ]]
then
  apt-get update
  apt install --yes docker-buildx
fi

docker-compose up -d
