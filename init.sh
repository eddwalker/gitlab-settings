#!/usr/bin/env bash

set -e

# Replace this server ssh port to let gitlab server to expose port 22 
sudo sed -E -i'' 's|(#)?Port.*|Port=10022|' /etc/ssh/sshd_config
systemctl restart sshd

# Install required software
apt update
apt install docker-compose docker-buildx --yes

# Run every docker container from this repo
for i in $(find . -type f -name up.sh); do
  ./$i
done
