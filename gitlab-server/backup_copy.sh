#!/usr/bin/env bash
# Script create gitlab server backup on $remote_addr host and pull backup to local system to $dst_dir.
# Run: on some remote host, not on gitlab node/container

set -e

remote_addr=10.10.9.169
remote_port=10022

dst_dir=../gitlab-backups/

export RSYNC_RSH="ssh -p $remote_port"

echo "copy: execute backup script on $remote_addr:$remote_port .."
ssh \
    -p $remote_port \
    $remote_addr \
    "bash -s" < ./backup_create.sh

echo "copy: copy backup from outside on container.."
rsync \
    -arv \
    --remove-source-files \
    --rsync-path="sudo rsync" \
    $remote_addr:/opt/gitlab/data/backups/ \
    $dst_dir

echo "copy: OK"
