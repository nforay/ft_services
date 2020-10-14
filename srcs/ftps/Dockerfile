FROM alpine:latest

MAINTAINER nforay

EXPOSE 21 30000-30004

RUN apk update
RUN apk add openrc openssl vsftpd
RUN openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/vsftpd.key \
      -out /etc/ssl/certs/vsftpd.crt \
      && mkdir -p /run/openrc \
      && touch /run/openrc/softlevel \
      && adduser -h /home/./ftps -D ftps \
      && echo "ftps:password" | chpasswd

VOLUME /sys/fs/cgroup

COPY /srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf

ENTRYPOINT ["sh", "-c", "rc-status; rc-service vsftpd start; crond -f"]
