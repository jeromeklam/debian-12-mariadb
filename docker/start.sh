#!/bin/bash
# Starts up MariaDB within the container.

# Stop on error
set -e
run="normal"

if [ -d /data ]; then
  if [ -f /data/firstrun.ok ]; then
    echo "normal run..."
    source /scripts/normal_run.sh
  else
    run="first"
    echo "first run..."
    source /scripts/first_run.sh
  fi
else
  if [ -f /var/lib/mysql/firstrun.ok ]; then
    echo "normal run..."
    source /scripts/normal_run.sh
  else
    run="first"
    echo "first run..."
    source /scripts/first_run.sh
  fi
fi

wait_for_mysql_and_run_post_start_action() {
  # Wait for mysql to finish starting up first.
  echo -n "."
  echo "$run"
  if [ "$run" = "normal" ]; then
    test=`/etc/init.d/mariadb status | grep Uptime`
  else
    test=""
  fi
  echo "$test"
  while [ "X$test" = "X" ]; do 
      sleep 2
      echo -n "."
      if [ "$run" = "normal" ]; then
        test=`/etc/init.d/mariadb status | grep Uptime`
      else
        test=`ps -fe | grep mysqld_safe`
      fi
      echo "$test"
  done
  echo "! done"
  echo "post_start_action..."
  post_start_action
  echo "post_start_action ok..."
}

echo "pre_start_action..."
pre_start_action
echo "pre_start_action ok"

wait_for_mysql_and_run_post_start_action

# Infinite loop
tail -f /dev/null
