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

## Как установить GNU parallel на Windows с Git Bash ?

[Источник](https://gist.github.com/AndreSteenveld/cb6662c93c8323795c5fd347defb8976)
[Репозиторий пакетов MSYS](https://packages.msys2.org/queue)

Если не будет ключа, то его можно скачать через 

Сначала нужно установить pacman
```sh
cd ~/Downloads
curl -L --remote-name-all https://mirror.msys2.org/msys/x86_64/{msys2-keyring-1~20260214-1-any,pacman-mirrors-20260129-1-any,pacman-6.1.0-25-x86_64}.pkg.tar.zst

cd /c/Program\ Files/Git/
tar x -vf ~/Downloads/msys2-keyring-1*.pkg.tar ./usr
tar x -vf ~/Downloads/pacman-mirrors-*.pkg.tar ./etc
tar x -vf ~/Downloads/pacman-*x86_64.pkg.tar ./usr
# Файл конфигурации
curl -Lo ./etc/pacman.conf 'https://raw.githubusercontent.com/git-for-windows/git-sdk-64/main/etc/pacman.conf' 
```

```sh
pacman -Sy --overwrite '*' parallel
```

Если выводит, значит всё ок.
```sh
parallel --max-line-length-allowed
32000
```
