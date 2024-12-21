MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:-super}
MYSQL_ADMIN_PASS=${MYSQL_ADMIN_PASS:-YggDrasil}

pre_start_action() {
  echo "MARIADB_USER=$MYSQL_ADMIN_USER"
  echo "MARIADB_PASS=$MYSQL_ADMIN_PASS"
  echo "moving..."
  rm -f /run/mysqld/mysqld.sock
  mv /var/lib/mysql /data/mysql
  ln -sf /data/mysql /var/lib/mysql
  ls -l /data/mysql
  echo "moving done..."
  chown -R mysql:mysql /data
  chown mysql:mysql /var/lib/mysql
  touch /data/firstrun.ok
  echo "starting in safe mode..."
  /usr/bin/mysqld_safe &
}

post_start_action() {
  # The password for 'debian-sys-maint'@'localhost' is auto generated.
  # So, we need to set this for our database to be portable.
  mariadb -u root <<-EOF
      CREATE USER '$MYSQL_ADMIN_USER'@'$MYSQL_ADMIN_HOST' IDENTIFIED BY '$MYSQL_ADMIN_PASS';
      GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_USER'@'$MYSQL_ADMIN_HOST' WITH GRANT OPTION;
EOF
  echo "creating users..."
  # Create the superuser, ...
  mariadb -u root <<-EOF
      DELETE FROM mysql.user WHERE user = 'sapaig';
      FLUSH PRIVILEGES;
      CREATE USER 'sapaig' IDENTIFIED BY 'SapaigMariadb10';
      GRANT ALL PRIVILEGES ON *.* TO 'sapaig'@'localhost' IDENTIFIED BY 'SapaigMariadb10';
      GRANT ALL PRIVILEGES ON *.* TO 'sapaig'@'%' IDENTIFIED BY 'SapaigMariadb10';
      FLUSH PRIVILEGES;
EOF

  echo "verifying dumps..."
  if [ "$DUMP" != "" ]; then
    set -f                      # avoid globbing (expansion of *).
    echo "processing $DUMP..."
    array=(${DUMP//:/ })
    for i in "${!array[@]}"
    do
      crt=${array[i]}
      if [ -f $crt ]; then
        echo "importing $crt..."
        filename=$(basename "$crt")
        extension="${filename##*.}"
        filename="${filename%.*}"
        mariadb -usuper -pYggDrasil -e "CREATE DATABASE \`$filename\`;"
        mysql -usuper -pYggDrasil "$filename" < "$crt"
        echo "done."
      else
        echo "$crt not found !"
      fi
    done
  else
    echo "nothing..."
  fi
  echo "stopping mysqld_safe"
  mysqladmin shutdown
  echo "Starting MariaDB..."
  service mariadb start
}
