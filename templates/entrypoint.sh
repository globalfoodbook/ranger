#!/bin/bash
# export MARIADB_HOST_IP=`awk 'NR==1 {print $1}' /etc/hosts`

# set -e
source /usr/bin/fxn.sh
# set -x #use then debuging

if [[ ! -d $MOUNT ]]; then
  mkdir -p $MOUNT
fi

NOW=$(date +"%Y-%m-%d-%H%M")
env > /root/.env

if [[ $AWS_S3 ]];
then
  if [[ ! -f ~/.passwd-s3fs || ! -f /etc/passwd-s3fs ]];
  then
    echo $AWS_S3 >> ~/.passwd-s3fs && cp ~/.passwd-s3fs /etc/passwd-s3fs

    chmod 600 ~/.passwd-s3fs
    chmod 640 /etc/passwd-s3fs
  fi
elif [[ $GCS_AUTH ]];
then
  if [[ ! -f $GCS_AUTH_FILE ]];
  then
    # echo $GCS_AUTH >> ~/.gcs-auth.txt && cp ~/.gcs-auth.txt $GCS_AUTH_FILE
    echo $GCS_AUTH >> $GCS_AUTH_FILE

    chmod 600 $GCS_AUTH_FILE
  fi
fi

if [[ $MARIADB_PORT_3306_TCP_ADDR ]];
then
  export IP_SUBNET_WILDCARD=${MARIADB_PORT_3306_TCP_ADDR/%?/}%;
  counter=0;
  while ! nc -vz $MARIADB_PORT_3306_TCP_ADDR $MARIADB_PORT_3306_TCP_PORT; do
    counter=$((counter+1));
    if [ $counter -eq 6 ]; then break; fi;
    sleep 10;
  done

  subdirectories=`find $BACKUP -maxdepth 1 -type d | wc -l`
  path_to_sql_dump="";
  if [[ -f $BACKUP/dump.sql ]];
  then
    path_to_sql_dump="$BACKUP/dump.sql";
  elif [[ -f $BACKUP/gfb.sql ]];
  then
    path_to_sql_dump="$BACKUP/gfb.sql";
  fi

  if [[ $path_to_sql_dump ]];
  then
    initiate_db
    restore_db $path_to_sql_dump

    sudo mv $path_to_sql_dump $BACKUP/"used_dump_on_$NOW.sql"
  elif [[ subdirectories -le 1 ]] && [[ $GCS_AUTH || $AWS_S3 ]];
  then
    initiate_db
    mount_cloud_storage

    recovery_dir="$BACKUP/recover-$NOW"
    mkdir -p $recovery_dir
    latest_dump_path=`find "$MOUNT/data" -type f|sort -r|head -n1`
    dump_file=`basename $latest_dump_path .tar.gz`

    tar -xzvf $latest_dump_path -C $recovery_dir

    restore_db "$recovery_dir$BACKUP/$dump_file"
  fi
fi

sudo rsyslogd
sudo tail -F /var/log/syslog
