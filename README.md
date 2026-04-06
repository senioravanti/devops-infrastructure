# Пример переменных среды

`.env` :: переменные docker-compose
Пароль portainer генерирурется скриптом `./portainer/create-env.sh`

```sh
POSTGRES_TAG=18-alpine3.23
MONGO_TAG=8.2.6-noble
GARAGE_TAG=v2.2.0
RABBITMQ_TAG=4.2.5-management-alpine
VALKEY_TAG=9.0.3-alpine3.23
NGINX_TAG=1.29.7-alpine3.23

# tls
SSL_PATH=/etc/ssl/private/<домен>
```
