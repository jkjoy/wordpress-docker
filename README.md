## Wordpress on Nginx using Sqlite instead of MySQL Dockerfile


This repository contains **Dockerfile** of Wordpress on Nginx using Sqlite instead of MySQL


### Usage

```bash
    docker run -d -p 80:80 jkjoy/wordpress
```
After few seconds, open `http://<host>` to see the wordpress install page.


### environment variables
```
    environment:
      - WP_HOME=http://localhost #不设置则自动获取域名
      - WP_SITEURL=http://localhost #不设置则自动获取域名
      - FORCE_SSL_LOGIN=false #默认为true  强制https登录
      - FORCE_SSL_ADMIN=false #默认为true  强制https管理后台
      - HTTPS_ENABLED=false #默认为true  启用https
```
