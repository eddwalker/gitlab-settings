#!/usr/bin/env bash
# Run on node with gitlab server

set -e

docker_name=gitlab-server_web_1

echo "info: detect docker containber ID .. "
docker_id="$(sudo docker ps -q --filter 'name='"$docker_name"'' 2>&1)"

if [[ ! $docker_id =~ ^[0-9A-z]+$ ]]
then
    echo "error: cannot detect docker id for $docker_name: $docker_id"
    exit 1
fi

echo "info: creating backup .. "
backup_output="$(sudo docker exec $docker_id bash -c "gitlab-backup create" 2>&1 || true)"

if ! [[ "$backup_output" =~ ^.*\ Backup\ ([^$'\n']+)\ is\ done ]]
then
    echo "error: backup output has NO filename: $backup_output"
    exit 1
fi

echo "info: backup is done to file: /var/opt/gitlab/backups/${BASH_REMATCH[1]}_gitlab_backup.tar"
