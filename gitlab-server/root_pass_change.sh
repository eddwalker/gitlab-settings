#!/usr/bin/env bash
# Change root password from gitlab console

set -e

docker_name=gitlab-server_web_1

sudo docker exec -t $docker_name gitlab-rake "gitlab:password:reset[root]"
