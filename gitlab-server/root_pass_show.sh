#!/usr/bin/env bash
# Return a gitlab web interface password for root.
# Working 24h after the gitlab install time.

set -e

docker_name=gitlab-server_web_1
password_path=/etc/gitlab/initial_root_password

docker_id="$(docker ps -q --filter 'name='"$docker_name"'' 2>&1 || true)"

if [[ ! $docker_id =~ ^[0-9A-z]+$ ]]
then
    echo "error: cannot detect docker id for $docker_name: $docker_id"
    exit 1
fi

docker exec $docker_id grep -oP 'Password:\s*\K.+' $password_path
