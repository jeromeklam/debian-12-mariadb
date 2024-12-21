######## INSTALL ########

# Set the base image
FROM freeasso/debian-12

ENV DEBIAN_FRONTEND=noninteractive

## Install MariaDB.
ENV INITRD=No
ENV MYSQL_ADMIN_PASS=password
ENV MYSQL_ADMIN_USER=admin
ENV MYSQL_ADMIN_HOST=%

# Supervisor
RUN apt-get update
#COPY ./docker/supervisord.conf /etc/supervisor/conf.d/mariadb.conf

RUN apt-get update && apt-get install -y mariadb-server
COPY ./docker/mariadb.cnf /etc/mysql/mariadb.cnf
RUN sed -e 's/bind-address/#bind-address/g' < /etc/mysql/mariadb.conf.d/50-server.cnf > /etc/mysql/mariadb.conf.d/50-server.cnf
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

ADD docker /scripts

RUN mkdir -p /data
RUN mkdir -p /dumps
# Expose our data, log, and configuration directories.
VOLUME ["/var/log/mysql", "/dumps", "/data", "/etc/mysql"]

EXPOSE 3306

# Use baseimage-docker's init system.
RUN chmod +x /scripts/start.sh

## On démarre mysql, ...
CMD ["/scripts/start.sh"]
