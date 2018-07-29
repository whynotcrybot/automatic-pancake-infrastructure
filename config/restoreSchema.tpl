#!/bin/bash

yum -y update
yum -y install mysql

cat <<EOF >>/tmp/mysql-query.sql
CREATE TABLE users (
  id int(11) NOT NULL,
  email varchar(256) NOT NULL,
  password varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF

export MYSQL_PWD=${DATABASE_PASSWORD}

mysql --host=${DATABASE_ENDPOINT} \
  --port=${DATABASE_PORT} \
  --user=${DATABASE_USER} \
  ${DATABASE_NAME} \
  < /tmp/mysql-query.sql

shutdown -h now
