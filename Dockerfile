FROM alpine:latest as wordpress-downloader
RUN apk --update add --no-cache curl tar
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
RUN mkdir -p /app && tar -xzvf wordpress.tar.gz --strip-components=1 --directory /app

FROM nginx:stable-alpine
WORKDIR /app

RUN apk --update add --no-cache \
    curl \
    php83 \
    php83-pdo \
    php83-sqlite3 \
    php83-zip \
    php83-curl \
    php83-gd \
    php83-intl \
    php83-mbstring \
    php83-dom \
    php83-json \
    php83-openssl \
    php83-pdo_sqlite \
    php83-zlib \
    php83-fileinfo \
    php83-opcache \
    php83-redis \
    php83-sodium \
    && rm -rf /var/cache/apk/*

COPY --from=wordpress-downloader /app /app
COPY sqlite-database-integration /app/wp-content/plugins/sqlite-database-integration
COPY config.php /app/wp-config.php
RUN cp /app/wp-content/plugins/sqlite-database-integration/db.copy /app/wp-content/db.php

RUN chown -R nginx:nginx /app && chmod -R 755 /app

RUN sed -i -e "s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf \
    && sed -i -e "s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/" /etc/nginx/nginx.conf \
    && sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf \
    && sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php83/php.ini \
    && sed -i -e 's/upload_max_filesize\s*=\s*2M/upload_max_filesize = 200M/g' /etc/php83/php.ini \
    && sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php83/php.ini \
    && sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e "s|listen = 127.0.0.1:9000|listen = /run/php-fpm83.sock|g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e "s|;listen.owner = nobody|listen.owner = nginx|g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e "s|;listen.group = nobody|listen.group = nginx|g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e "s|user = nobody|user = nginx|g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e "s|group = nobody|group = nginx|g" /etc/php83/php-fpm.d/www.conf \
    && sed -i -e 's/;extension=sockets/extension=sockets/g' \
          -e 's/;extension=sodium/extension=sodium/g' \
          -e 's/;extension=sqlite3/extension=sqlite3/g' \
          -e 's/;extension=zip/extension=zip/g' \
          -e 's/;zend_extension=opcache/zend_extension=opcache/g' \
          /etc/php83/php.ini

COPY default /etc/nginx/sites-available/default
RUN mkdir -p /etc/nginx/sites-enabled \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80 443
CMD ["/start.sh"]
