# First stage: Download WordPress
FROM alpine:latest AS wordpress-downloader

RUN apk --no-cache add curl tar && \
    curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    mkdir -p /app && \
    tar -xzvf wordpress.tar.gz --strip-components=1 --directory /app && \
    rm wordpress.tar.gz

# Second stage: Set up Nginx and PHP
FROM nginx:stable-alpine

# Set working directory
WORKDIR /app

# Install PHP and necessary extensions
RUN apk --no-cache add \
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
    php83-sodium && \
    rm -rf /var/cache/apk/*

# Copy WordPress files and other resources
COPY --from=wordpress-downloader /app /app
COPY sqlite-database-integration /app/wp-content/plugins/sqlite-database-integration
COPY config.php /app/wp-config.php
RUN cp /app/wp-content/plugins/sqlite-database-integration/db.copy /app/wp-content/db.php

# Set permissions
RUN chown -R nginx:nginx /app && \
    chmod -R 755 /app 

# Configure Nginx
RUN sed -i -e "s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e "s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/" /etc/nginx/nginx.conf && \
    sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf

# Configure PHP-FPM
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php83/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php83/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php83/php.ini && \
    sed -i -e "s/;catch_workers_output\s*=.*/catch_workers_output = yes/g" /etc/php83/php-fpm.d/www.conf && \
    sed -i -e "s/;listen.mode = .*/listen.mode = 0666/g" /etc/php83/php-fpm.d/www.conf && \
    sed -i -e "s|listen = 127.0.0.1:9000|listen = /run/php-fpm83.sock|g" /etc/php83/php-fpm.d/www.conf && \
    sed -i -e "s|;listen.owner = .*|listen.owner = nginx|g" /etc/php83/php-fpm.d/www.conf && \
    sed -i -e "s|;listen.group = .*|listen.group = nginx|g" /etc/php83/php-fpm.d/www.conf && \
    sed -i -e "s|user = .*|user = nginx|g" /etc/php83/php-fpm.d/www.conf && \
    sed -i -e "s|group = .*|group = nginx|g" /etc/php83/php-fpm.d/www.conf && \
    sed -i 's/;extension=ctype/extension=ctype/' /etc/php83/php.ini && \
    sed -i 's/;extension=tokenizer/extension=tokenizer/' /etc/php83/php.ini && \
    sed -i -e 's/;extension=sockets/extension=sockets/g' \
    -e 's/;extension=sodium/extension=sodium/g' \
    -e 's/;extension=sqlite3/extension=sqlite3/g' \
    -e 's/;extension=zip/extension=zip/g' \
    -e 's/;zend_extension=opcache/zend_extension=opcache/g' \
    /etc/php83/php.ini

# Configure Nginx site
COPY default /etc/nginx/sites-available/default
RUN mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports
EXPOSE 80 443

# Start the application
CMD ["/start.sh"]
