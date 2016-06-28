initiate_db(){
  sql="$(cat /root/schema.sql)"
  echo $(eval echo \"$sql\") > /root/.temp.sql
  /usr/bin/mysql -h$MARIADB_PORT_3306_TCP_ADDR -uroot -p$MARIADB_ENV_MYSQL_ROOT_PASSWORD < /root/.temp.sql

  rm /root/.temp.sql
}

restore_db() {
  /usr/bin/mysql -h$MARIADB_PORT_3306_TCP_ADDR -uroot -p$MARIADB_ENV_MYSQL_ROOT_PASSWORD $MARIADB_ENV_MARIADB_DATABASE < $1
}

dump_db() {
  /usr/bin/mysqldump -h$MARIADB_PORT_3306_TCP_ADDR -uroot -p$MARIADB_ENV_MYSQL_ROOT_PASSWORD $MARIADB_ENV_MARIADB_DATABASE > $1
}

mount_cloud_storage() {
  # Add -odefault_acl=public-read to GCS or S3 to allow public read
  if [[ $GCS_AUTH ]];
  then
    /usr/bin/s3fs $GCS_BUCKET $MOUNT -onomultipart -opasswd_file=$GCS_AUTH_FILE -osigv2 -ourl=https://storage.googleapis.com -ouse_path_request_style -ouse_cache=/tmp -ononempty
  elif [[ $AWS_S3 ]];
  then
    /usr/bin/s3fs $S3_BUCKET $MOUNT -ouse_cache=/tmp -ononempty
  fi
}
