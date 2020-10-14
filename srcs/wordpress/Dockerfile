FROM alpine:latest

MAINTAINER nforay

EXPOSE 5050

RUN apk update
RUN apk add openrc openssl curl php7 php7-fpm php7-mbstring php7-mysqli php7-session php7-json nginx 
RUN openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/wordpress.key \
      -out /etc/ssl/certs/wordpress.crt \
      && openssl dhparam -out /etc/ssl/certs/dhparam.pem 1024 \
      && mkdir -p /run/openrc \
      && touch /run/openrc/softlevel

COPY /srcs/wordpress.conf /etc/nginx/conf.d/wordpress.conf

COPY /srcs/wordpress.tar.gz /var/www/localhost/htdocs/wordpress.tar.gz

WORKDIR /var/www/localhost/htdocs/

RUN tar -xzf wordpress.tar.gz \
      && chgrp -R www-data /var/www/localhost/htdocs \
      && rm -r wordpress.tar.gz \
      && sed -i "s/user = nobody/user = nginx/" /etc/php7/php-fpm.d/www.conf
COPY /srcs/wp-config.php wp-config.php

WORKDIR /

VOLUME /sys/fs/cgroup

ENTRYPOINT ["sh", "-c", "ssh-keygen -A; rc-status; rc-service php-fpm7 start; rc-service nginx start; crond -f"]