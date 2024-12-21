pre_start_action() {
  echo "Starting MariaDB..."
  service mariadb start
}

post_start_action() {
  # nothing
  echo "."
}
