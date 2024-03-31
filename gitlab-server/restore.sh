#!/usr/bin/env bash
# List of backups or restore choosen one.
#
# Call for create backup and move backup to local $dst_dir.
# For run on some remote host, not on gitlab node/container
# FYI: https://askubuntu.com/questions/719439/using-rsync-with-sudo-on-the-destination-machine

set -e

remote_addr=10.10.9.169
remote_port=10022
remote_path=/opt/gitlab/data/backups

dst_dir=../gitlab-backups/

export RSYNC_RSH="ssh -p $remote_port"

if [[ ! -n $1 ]]
then
    echo "To restore backup give as param one of next local backups:"
    ls -la "$dst_dir"
    exit 0
fi

restore_file=$1

echo "restore: check backup is operable .."

if [[ ! $restore_file =~ _gitlab_backup.tar$ ]]
then
    restore_file_fullname=${restore_file}_gitlab_backup.tar
else
    restore_file_fullname=${restore_file}
fi
restore_file_short=${restore_file_fullname%%_gitlab_backup.tar}

if [[ -f $dst_dir/$restore_file_fullname ]]
then
    echo "restore: backup file exists: $dst_dir/$restore_file_fullname"
else
    echo "restore: cannot find backup file: $dst_dir/$restore_file_fullname"
    exit 1
fi

echo "restore: upload backup to $remote_addr:$remote_port:$remote_path/ .."
rsync \
    -arv \
    --rsync-path="sudo rsync" \
    $dst_dir/$restore_file_fullname \
    $remote_addr:$remote_path/ \

echo "restore: calling restore on $remote_addr:$remote_port .."
ssh \
    -p $remote_port \
    $remote_addr \
    /bin/bash << EOF
       set -e
       echo "runnig gitlab-ctl reconfigure to avoid stuck on restore .. "
       sudo docker exec gitlab_web_1 gitlab-ctl reconfigure

       echo "disable services .."
       sudo docker exec gitlab_web_1 gitlab-ctl stop puma
       sudo docker exec gitlab_web_1 gitlab-ctl stop sidekiq

       echo "restore backup .."
       sudo docker exec gitlab_web_1 bash -c "chown git:git /var/opt/gitlab/backups/*"
       sudo docker exec --env=GITLAB_ASSUME_YES=1 gitlab_web_1 gitlab-backup restore BACKUP=$backup_file_short

       echo "restart docker copntainer .."
       sudo docker restart gitlab_web_1

       echo "sanitize gitlab .."
       sudo docker exec gitlab_web_1 gitlab-rake gitlab:check SANITIZE=true

       # if database has encrypted secrets
       #   sudo gitlab-rake gitlab:doctor:secrets
       # For added assurance, you can perform an integrity check on the uploaded files:
       #   sudo gitlab-rake gitlab:artifacts:check
       #   sudo gitlab-rake gitlab:lfs:check
       #   sudo gitlab-rake gitlab:uploads:check
EOF

echo "restore: OK"
echo "gitlab site must return now status 502 and will became operable in one minute."
