FROM alpine:latest

MAINTAINER nforay

EXPOSE 3306

RUN apk update
RUN apk add openrc mariadb mariadb-client mariadb-server-utils
RUN mkdir -p /run/openrc \
      && touch /run/openrc/softlevel

VOLUME /sys/fs/cgroup

COPY ./srcs/startup.sh /root/startup.sh
COPY ./srcs/create.sql /root/create.sql
COPY ./srcs/wordpress.sql /root/wordpress.sql

ENTRYPOINT ["sh", "-c", "rc-status; sh /root/startup.sh; crond -f"]
