#!/usr/bin/env bash
set -e

if [ ! -d /opt/certbot/ ]; then
  echo 'installing certbot ...'
  mkdir /opt/certbot/
  python3 -m venv /opt/certbot/
  /opt/certbot/bin/pip install --upgrade pip
  /opt/certbot/bin/pip install certbot
  ln -s /opt/certbot/bin/certbot /usr/bin/certbot
fi

certbot renew -q

SSL_PATHS=(
  '/etc/ssl/private/senioravanti.ru/postgres'
  '/etc/ssl/private/senioravanti.ru/vault'
)

copy_certs() {
  local SSL_PATH="$1"
  local SSL_OWNER

  case "$SSL_PATH" in
  "${SSL_PATHS[0]}") SSL_OWNER='70:70';;
  "${SSL_PATHS[1]}") SSL_OWNER='100:1000';;
  *) echo 'unknown ssl path'; exit 1;;
  esac

  cp /etc/letsencrypt/live/senioravanti.ru/{privkey.pem,fullchain.pem} "${SSL_PATH}/"
  
  chmod 600 "${SSL_PATH}/privkey.pem"
  chmod 644 "${SSL_PATH}/fullchain.pem"
  
  chown "$SSL_OWNER" "${SSL_PATH}/privkey.pem"
}

for IT in "${SSL_PATHS[@]}"; do
  if [ ! -d "$IT" ]; then
    echo "creating ${IT}/ ..."
    mkdir "${IT}/"
    copy_certs "$IT"
  fi
done