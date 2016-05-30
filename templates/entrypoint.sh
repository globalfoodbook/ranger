#!/bin/bash
# export MYSQL_HOST_IP=`awk 'NR==1 {print $1}' /etc/hosts`

NOW=$(date +"%Y-%m-%d-%H%M")
env > /root/.env

set -e
# set -x #use then debuging

if [[ ! -f ~/.passwd-s3fs || ! -f /etc/passwd-s3fs ]];
then
  echo $AWS_S3 >> ~/.passwd-s3fs && cp ~/.passwd-s3fs /etc/passwd-s3fs

  chmod 600 ~/.passwd-s3fs
  chmod 640 /etc/passwd-s3fs
fi

if [[ $MYSQL_PORT_3306_TCP_ADDR ]];
then
  counter=0;
  while ! nc -vz $MYSQL_PORT_3306_TCP_ADDR $MYSQL_PORT_3306_TCP_PORT; do
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
    sql="$(cat /root/schema.sql)"
    echo $(eval echo \"$sql\") > /root/.temp.sql
    mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD < /root/.temp.sql

    rm /root/.temp.sql

    mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD $MYSQL_ENV_MYSQL_DATABASE < $path_to_sql_dump
    sudo mv $path_to_sql_dump $BACKUP/"used_dump_on_$NOW.sql"
  elif [[ subdirectories -le 1 ]]
    /usr/bin/s3fs $S3_BUCKET $MOUNT -ouse_cache=/tmp -odefault_acl=public-read -ononempty

    recovery_dir="$BACKUP/recover-$NOW"
    mkdir -p $recovery_dir
    latest_dump_path=`find "/mnt/s3b/data" -type f|sort -r|head -n1`
    dump_file=`basename $latest_dump_path .tar.gz`

    tar -xzvf $latest_dump_path -C $recovery_dir

    mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD $MYSQL_ENV_MYSQL_DATABASE < $recovery_dir$BACKUP/$dump_file
  fi
fi

sudo rsyslogd
sudo tail -F /var/log/syslog
