FROM alpine:latest

MAINTAINER nforay

EXPOSE 3000

RUN apk update
RUN apk add syslog-ng openrc \
      && apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing grafana-openrc \
      && apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing grafana \
      && sed -i 's/grafana:grafana/root:root/g' /etc/init.d/grafana \
      && mkdir -p /run/openrc \
      && touch /run/openrc/softlevel \
      && sed -i '/^cfg:server.http_addr/d' etc/conf.d/grafana \
      && mkdir -p /var/lib/grafana/provisioning/datasources \
      && mkdir /var/lib/grafana/dashboards

COPY /srcs/grafana.ini /etc/grafana.ini
COPY /srcs/datasource.yaml /var/lib/grafana/provisioning/datasources/
COPY /srcs/dashboard.yaml /var/lib/grafana/provisioning/dashboards/
COPY ./srcs/*.json /var/lib/grafana/dashboards/

VOLUME /sys/fs/cgroup

ENTRYPOINT ["sh", "-c", "rc-status; rc-service syslog-ng start; rc-service grafana start; crond -f"]
