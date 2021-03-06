# set base os
FROM linuxserver/baseimage.nginx

MAINTAINER Mark Burford <sparklyballs@gmail.com>, Kode <kodestar@linuxserver.io>

# set some environment variables for mariadb to give us our paths
ENV MYSQL_DIR="/config/mysql"
ENV DATADIR=$MYSQL_DIR/databases

# set the repo version for mariadb choose between 5.5 or 10.0
ENV REPO_VER 10.0

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# set ports
EXPOSE 443 3306

# add mariadb repo
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
add-apt-repository "deb http://mirrors.coreix.net/mariadb/repo/$REPO_VER/ubuntu trusty main"

# update apt and install packages
RUN apt-get update && \
apt-get install \
mariadb-server \
php5-mysql \
php5-pgsql \
wget \
unzip -qy && \
apt-get clean -y && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install mysqltuner
RUN apt-get update -q && \
apt-get install \
mysqltuner -qy && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Tweak my.cnf
RUN sed -ri 's/^(bind-address|skip-networking)/;\1/' /etc/mysql/my.cnf && \
sed -i s#/var/log/mysql#/config/log/mysql#g /etc/mysql/my.cnf && \
sed -i -e 's/\(user.*=\).*/\1 abc/g' /etc/mysql/my.cnf && \
sed -i -e "s#\(datadir.*=\).*#\1 $DATADIR#g" /etc/mysql/my.cnf

#Adding Custom files
RUN mkdir -p /defaults 
ADD defaults/ /defaults/ 
RUN cp /etc/mysql/my.cnf /defaults/my.cnf
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh
