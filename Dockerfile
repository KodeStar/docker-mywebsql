# set base os
FROM linuxserver/baseimage.nginx

MAINTAINER Mark Burford <sparklyballs@gmail.com>

# set some environment variables
ENV DATADIR="/config/databases"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# set ports
EXPOSE 80 443 3306

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

# tweak my.cnf
RUN sed -i -e 's#\(log_error.*=\).*#\1 /config/databases/mysql_safe.log#g' /etc/mysql/my.cnf && \
sed -i -e 's/\(user.*=\).*/\1 abc/g' /etc/mysql/my.cnf && \
sed -i -e "s#\(datadir.*=\).*#\1 $DATADIR#g" /etc/mysql/my.cnf

#Adding Custom files
RUN mkdir -p /defaults 
ADD defaults/ /defaults/ 
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh
