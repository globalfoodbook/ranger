#!/bin/bash
# export MYSQL_HOST_IP=`awk 'NR==1 {print $1}' /etc/hosts`

# NOW=$(date +"%Y-%m-%d-%H%M")

# DUMP_FILE="/dumps/dump.sql"

if [[ ! -f ~/.passwd-s3fs || ! -f /etc/passwd-s3fs ]];
then
  echo $AWS_S3 >> ~/.passwd-s3fs && cp ~/.passwd-s3fs /etc/passwd-s3fs

  chmod 600 ~/.passwd-s3fs
  chmod 640 /etc/passwd-s3fs
fi

counter=0
while ! nc -vz $MYSQL_PORT_3306_TCP_ADDR $MYSQL_PORT_3306_TCP_PORT; do
  counter=$((counter+1));
  if [ $counter -eq 60 ]; then break; fi;
  sleep 1;
done

if [[ -f /dumps/dump.sql || -f /dumps/gfb.sql ]];
then
  sql="$(cat /root/schema.sql)"
  echo $(eval echo \"$sql\") > /root/.temp.sql
  mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD < /root/.temp.sql

  rm /root/.temp.sql

  mysql -h$MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD $MYSQL_ENV_MYSQL_DATABASE < /dumps/dump.sql
fi

rsyslogd
cron
touch /var/log/cron.log
tail -F /var/log/syslog /var/log/cron.log
