FROM alpine:latest

MAINTAINER nforay

EXPOSE 80 443

RUN apk update
RUN apk add nginx openrc openssl
RUN openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/localhost.key \
      -out /etc/ssl/certs/localhost.crt \
      && openssl dhparam -out /etc/ssl/certs/dhparam.pem 1024 \
      && mkdir -p /run/openrc \
      && touch /run/openrc/softlevel

COPY /srcs/localhost.conf /etc/nginx/conf.d/localhost.conf
COPY /srcs/index.html /var/www/localhost/htdocs
RUN chgrp -R www-data /var/www/localhost/htdocs
RUN rm /etc/nginx/conf.d/default.conf

VOLUME /sys/fs/cgroup

ENTRYPOINT ["sh", "-c", "rc-status; rc-service nginx start; crond -f"]
