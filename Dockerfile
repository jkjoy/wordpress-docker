from nginx:latest
MAINTAINER jkjoy <imsunpw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV DOCUMENT_ROOT /usr/share/nginx/html

#Install nginx php-fpm php-pdo unzip curl
RUN apt-get update 
RUN apt-get -y install php8.2-fpm unzip curl apt-utils php8.2-curl php8.2-gd php8.2-intl php-pear php8.2-imagick php8.2-imap php8.2-mcrypt php8.2-ps php8.2-pspell php8.2-sqlite php8.2-tidy php8.2-xmlrpc php8.2-xsl

RUN rm -rf ${DOCUMENT_ROOT}/*
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
RUN tar -xzvf /wordpress.tar.gz --strip-components=1 --directory ${DOCUMENT_ROOT}

RUN curl -o sqlite-plugin.zip https://downloads.wordpress.org/plugin/sqlite-database-integration.zip
RUN unzip sqlite-plugin.zip -d ${DOCUMENT_ROOT}/wp-content/plugins/
RUN rm sqlite-plugin.zip
RUN cp ${DOCUMENT_ROOT}/wp-content/plugins/sqlite-database-integration/db.copy ${DOCUMENT_ROOT}/wp-content/db.php
COPY config.php ${DOCUMENT_ROOT}/wp-config.php

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/" /etc/nginx/nginx.conf
RUN sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/8.2/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g" /etc/php/8.2/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g" /etc/php/8.2/fpm/php.ini
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/8.2/fpm/pool.d/www.conf
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php/8.2/fpm/pool.d/www.conf

RUN chown -R www-data:www-data ${DOCUMENT_ROOT}

COPY default /etc/nginx/sites-available/default
RUN mkdir -p /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

EXPOSE 80
EXPOSE 443

CMD service php8-fpm start && nginx
