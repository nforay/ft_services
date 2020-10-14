FROM alpine:latest

MAINTAINER nforay

EXPOSE 5000

RUN apk update
RUN apk add nginx openrc openssl php7 php7-fpm php7-mbstring php7-mysqli php7-session php7-json curl
RUN openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/phpmyadmin.key \
      -out /etc/ssl/certs/phpmyadmin.crt \
      && openssl dhparam -out /etc/ssl/certs/dhparam.pem 1024 \
      && mkdir -p /run/openrc \
      && touch /run/openrc/softlevel

COPY /srcs/phpmyadmin.conf /etc/nginx/conf.d/phpmyadmin.conf

RUN mkdir -p /var/www/localhost/htdocs/phpmyadmin \
      && curl --connect-timeout 5 --retry 5 -L https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz -o /var/www/localhost/htdocs/phpmyadmin/phpmyadmin.tar.gz

WORKDIR /var/www/localhost/htdocs/phpmyadmin
RUN tar -xzf phpmyadmin.tar.gz --strip-components 1 \
      && rm -r phpmyadmin.tar.gz \
      && mkdir tmp \
      && chgrp -R www-data /var/www/localhost/htdocs \
      && chown nginx tmp \
      && randomBlowfish=$(openssl rand -base64 32) \
      && sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfish'|" config.sample.inc.php > config.inc.php \
      && sed -i "s/user = nobody/user = nginx/" /etc/php7/php-fpm.d/www.conf \
      && sed -i "s/$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost'.*/$cfg\['Servers'\]\[\$i\]\['host'\] = 'mysql-svc.default.svc.cluster.local';/" /var/www/localhost/htdocs/phpmyadmin/config.inc.php \
      && echo "\$cfg['PmaAbsoluteUri'] = './';" >> /var/www/localhost/htdocs/phpmyadmin/config.inc.php

WORKDIR /
VOLUME /sys/fs/cgroup

ENTRYPOINT ["sh", "-c", "ssh-keygen -A; rc-status; rc-service php-fpm7 start; rc-service nginx start; crond -f"]
