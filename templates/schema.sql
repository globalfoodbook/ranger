DROP DATABASE IF EXISTS $MARIADB_ENV_MARIADB_DATABASE;
CREATE DATABASE $MARIADB_ENV_MARIADB_DATABASE;

FLUSH PRIVILEGES;

DROP USER IF EXISTS '$MARIADB_ENV_MARIADB_USER'@'localhost';
DROP USER IF EXISTS '$MARIADB_ENV_MARIADB_USER'@'$IP_SUBNET_WILDCARD';

FLUSH PRIVILEGES;

CREATE USER '$MARIADB_ENV_MARIADB_USER'@'localhost' IDENTIFIED BY '$MARIADB_ENV_MARIADB_PASSWORD';
CREATE USER '$MARIADB_ENV_MARIADB_USER'@'$IP_SUBNET_WILDCARD' IDENTIFIED BY '$MARIADB_ENV_MARIADB_PASSWORD';

GRANT ALL ON $MARIADB_ENV_MARIADB_DATABASE.* TO '$MARIADB_ENV_MARIADB_USER'@'localhost';
GRANT ALL ON $MARIADB_ENV_MARIADB_DATABASE.* TO '$MARIADB_ENV_MARIADB_USER'@'$IP_SUBNET_WILDCARD';

FLUSH PRIVILEGES;
