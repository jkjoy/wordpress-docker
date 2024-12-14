#!/bin/sh

# 检查 /app/data 目录是否为空
if [ -z "$(ls -A /app/data)" ]; then
    echo "/app/data 目录为空"
    cp -r /app/wp-content/* /app/data/
    echo "文件复制完成。"
else
    echo "/app/data 目录不为空，跳过。"
fi

# 检查 wp-config.php 是否存在
if [ ! -f /app/data/wp-config.php ]; then
    echo " wp-config.php 不存在"
    cp -r /app/wp-config.php /app/data/wp-config.php
    echo "文件复制完成。"
else
    echo " wp-config.php 存在，跳过。"
fi

# 检查 /app/data/themes 目录是否存在
if [ ! -d /app/data/themes ]; then
    echo "themes 目录不存在"
    cp -r /app/wp-content/themes /app/data/
    echo "themes 恢复完成。"
else
    echo "themes 目录存在，跳过。"
fi

# 设置 /app/data 目录的权限为可写
chmod -R 777 /app/data

# 创建符号链接
ln -sfn /app/data /app/wp-content
ln -sfn /app/data/wp-config.php /app/wp-config.php

# 启动 PHP-FPM
php-fpm83 --nodaemonize &

# 启动 Nginx
nginx -g "daemon off;"