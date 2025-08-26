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

if [ -z "$SSL_LETSENCRYPT_CA_PATH" ]; then
  SSL_LETSENCRYPT_CA_PATH='/etc/ssl/certs/isrgrootx1.pem'
fi

if [ ! -f "$SSL_LETSENCRYPT_CA_PATH" ]; then
  curl -sS -o "$SSL_LETSENCRYPT_CA_PATH" \
    https://letsencrypt.org/certs/isrgrootx1.pem
fi

process_certs() {
  local SSL_PATH="$1"
  local SSL_OWNER="$2"
  local IS_MERGE="$3"

  echo "copy cert \`${SSL_PATH}/\` ..."

  cp "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" "${SSL_PATH}/"
  chmod 644 "${SSL_PATH}/fullchain.pem"
    
  if [ "$IS_MERGE" == true ]; then
    cp "/etc/letsencrypt/live/${DOMAIN}/cert.pem" "${SSL_PATH}/"
    cat "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" >> "${SSL_PATH}/cert.pem"
    chmod 600 "${SSL_PATH}/cert.pem"
  else
    cp "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" "${SSL_PATH}/"
    chmod 600 "${SSL_PATH}/privkey.pem"
  fi

  chown -R "$SSL_OWNER" "${SSL_PATH}/"
}

while IFS=';' read -r SSL_PATH SSL_OWNER IS_MERGE; do
  if [ ! -d "$SSL_PATH" ]; then
    echo "creating \`${SSL_PATH}/\` ..."
    mkdir "${SSL_PATH}/"
    process_certs "$SSL_PATH" "$SSL_OWNER" "$IS_MERGE"
  fi
done <<-EOL
	/etc/ssl/private/${DOMAIN}/postgres;70:70;false
	/etc/ssl/private/${DOMAIN}/mongodb;999:999;true
	/etc/ssl/private/${DOMAIN}/valkey;999:1000;false
	/etc/ssl/private/${DOMAIN}/nginx;root:root;false
EOL
