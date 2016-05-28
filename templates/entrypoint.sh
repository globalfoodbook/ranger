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


  path_to_sql_dump="";
  if [[ -f /dumps/dump.sql ]];
  then
    path_to_sql_dump="/dumps/dump.sql";
  elif [[ -f /dumps/gfb.sql ]];
  then
    path_to_sql_dump="/dumps/gfb.sql";
  fi

  if [[ $path_to_sql_dump ]];
  then
    sql="$(cat /root/schema.sql)"
    echo $(eval echo \"$sql\") > /root/.temp.sql
    mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD < /root/.temp.sql

    rm /root/.temp.sql

    mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD $MYSQL_ENV_MYSQL_DATABASE < $path_to_sql_dump
    sudo mv $path_to_sql_dump /dumps/"used_dump_on_$NOW.sql"
  fi
fi

sudo rsyslogd
sudo tail -F /var/log/syslog
