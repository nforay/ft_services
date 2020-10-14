FROM alpine:latest

MAINTAINER nforay

EXPOSE 8086 8125

RUN apk update
RUN apk add openrc influxdb
RUN apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing telegraf \
      && apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing telegraf-openrc \
      && mkdir -p /run/openrc \
      && touch /run/openrc/softlevel

COPY /srcs/telegraf.conf /etc/telegraf.conf
COPY /srcs/influxdb_init.sh /root/influxdb_init.sh

VOLUME /sys/fs/cgroup

ENTRYPOINT ["sh", "-c", "rc-status; chgrp telegraf /var/run/docker.sock;rc-service influxdb start; sh /root/influxdb_init.sh; rc-service telegraf start; crond -f"]
