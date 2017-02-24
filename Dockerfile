FROM 2dotstwice/nginx

MAINTAINER Kristof Coomans "kristof@2dotstwice.be"
ENV REFRESHED_AT "2017-02-25 07:06:00"

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q install software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --fix-missing -q install php7.0-fpm php7.0-gd php7.0-sqlite php7.0-mysqlnd php7.0-curl php7.0-intl php7.0-xml php7.0-mbstring php7.0-opcache php7.0-json php7.0-mcrypt php7.0-bcmath php7.0-soap php7.0-zip

ENV CONFIG_REFRESHED_AT "2017-02-04 11:13:00"

# php configuration
ADD ./files/etc/php5/fpm/conf.d/99-custom.ini /etc/php/7.0/fpm/conf.d/99-custom.ini
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini

# php-fpm configuration
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN mkdir /run/php

# supervisor configuration for php-fpm
ADD ./files/etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

# nginx site configuration for php-fpm
ADD ./files/etc/nginx/sites-available/default /etc/nginx/sites-available/default

# Standard hosting package nginx configuration
# Reduce worker processes to 2, it's just a small site with not much traffic.
RUN sed -i -e "s/worker_processes 4/worker_processes 2/g" /etc/nginx/nginx.conf

# Standard hosting package php-fpm configuration
ADD ./files/etc/php5/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf