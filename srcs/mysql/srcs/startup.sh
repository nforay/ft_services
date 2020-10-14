#!/bin/bash

sed -i 's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf
echo "datadir=/var/lib/mysql" >> /etc/my.cnf.d/mariadb-server.cnf
if [ "$(ls -A /var/lib/mysql)" ]
then
  rc-service mariadb start
else
  /etc/init.d/mariadb setup
  rc-service mariadb start
  wget -P /root/ https://raw.githubusercontent.com/phpmyadmin/phpmyadmin/master/sql/create_tables.sql
  mysql -u root < /root/create_tables.sql
  mysql -u root < /root/create.sql
  mysql -u root -D wordpress < /root/wordpress.sql
fi
