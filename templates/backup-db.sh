#!/bin/bash
# export MARIADB_PORT_3306_TCP_ADDR=`awk 'NR==1 {print $1}' /etc/hosts`

# set -e
# set -x #use then debuging
source /usr/bin/fxn.sh
source /root/.env

if [ ! -d "$BACKUP" ]; then
  /bin/mkdir -p $BACKUP
fi

if [[ $GCS_AUTH || $AWS_S3 ]];
then
  NOW=$(date +"%Y-%m-%d-%H%M")
  DB_FILE="$MARIADB_ENV_MARIADB_DATABASE.$NOW.sql"

  mount_cloud_storage
  dump_db "$BACKUP/$DB_FILE"

  /bin/tar -czvf $BACKUP/"$DB_FILE.tar.gz" -P $BACKUP/$DB_FILE

  /bin/cp $BACKUP/"$DB_FILE.tar.gz" $MOUNT/data/
  # /bin/rm $BACKUP/"$DB_FILE.tar.gz" $BACKUP/"$DB_FILE"
fi

# MARIADB_PORT MARIADB_PORT_3306_TCP MARIADB_PORT_3306_TCP_ADDR MARIADB_PORT_3306_TCP_PORT MARIADB_PORT_3306_TCP_PROTO MARIADB_NAME MARIADB_ENV_MARIADB_ROOT_PASSWORD MARIADB_ENV_MARIADB_USER MARIADB_ENV_MARIADB_PASSWORD MARIADB_ENV_MARIADB_DATABASE MARIADB_ENV_AWS_S3 MARIADB_ENV_MARIADB_MAJOR MARIADB_ENV_MARIADB_VERSION REDIS_PORT REDIS_PORT_6379_TCP REDIS_PORT_6379_TCP_ADDR REDIS_PORT_6379_TCP_PORT REDIS_PORT_6379_TCP_PROTO REDIS_NAME REDIS_ENV_GOSU_VERSION REDIS_ENV_REDIS_VERSION REDIS_ENV_REDIS_DOWNLOAD_URL
