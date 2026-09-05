#!/usr/bin/env bash
set -eu

# default
force=false

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }

while getopts "hfd:" arg; do
  case "$arg" in
    f) force=true ;;
    d) domain="${OPTARG}" ;;
    h|*)
      usage
      exit 0
      ;;
  esac
done
shift $((OPTIND-1))

# envs
ssl_letsencrypt_path="/etc/letsencrypt/live/${domain}"
ssl_letsencrypt_ca_path="${SSL_LETSENCRYPT_CA_PATH:-/etc/ssl/certs/isrgrootx1.pem}"

if [ ! -d /opt/certbot/ ]; then
  echo 'installing certbot ...'
  mkdir /opt/certbot/
  python3 -m venv /opt/certbot/
  /opt/certbot/bin/pip install --upgrade pip
  /opt/certbot/bin/pip install certbot
  ln -s /opt/certbot/bin/certbot /usr/bin/certbot
fi

if [ ! -f "${ssl_letsencrypt_ca_path}" ]; then
  wget -O "${ssl_letsencrypt_ca_path}" https://letsencrypt.org/certs/isrgrootx1.pem
fi

process_certs() {
  local ssl_path="$1"
  local ssl_owner="$2"
  local cert_count="$3"

  echo "copy ${cert_count} cert(s) \`${ssl_path}/\` ..."

  case "${cert_count}" in
    1)
      cp "${ssl_letsencrypt_path}"/{cert,fullchain}.pem "${ssl_path}/"
      cat "${ssl_letsencrypt_path}/privkey.pem" >> "${ssl_path}/cert.pem"
      chmod 600 "${ssl_path}/cert.pem"
      chmod 644 "${ssl_path}/fullchain.pem"
      ;;
    3)
      cp "${ssl_letsencrypt_path}"/{cert,chain,privkey}.pem "${ssl_path}/"
      chmod 600 "${ssl_path}/privkey.pem"
      chmod 644 "${ssl_path}"/{chain,cert}.pem
      ;;
    *)
      cp "${ssl_letsencrypt_path}"/{privkey,fullchain}.pem "${ssl_path}/"
      chmod 600 "${ssl_path}/privkey.pem"
      chmod 644 "${ssl_path}/fullchain.pem"
      ;;
  esac

  chown -R "${ssl_owner}" "${ssl_path}/"
}

while IFS=';' read -r ssl_path ssl_owner cert_count; do
  if [[ ! -d "${ssl_path}" ]]; then
    echo "creating \`${ssl_path}/\` ..."
    mkdir -p "${ssl_path}/"
  else
    if [[ "${force}" == false ]]; then
      echo "\`${ssl_path}\` exists, skipping ..."
      continue
    fi
  fi
  echo "processing \`${ssl_path}/\` ..."
  process_certs "${ssl_path}" "${ssl_owner}" "${cert_count}"

done <<EOL
/etc/ssl/private/${domain}/postgres;70:70;2
/etc/ssl/private/${domain}/mongodb;999:999;1
/etc/ssl/private/${domain}/nginx;root:root;2
/etc/ssl/private/${domain}/k3s;root:root;2
/etc/ssl/private/${domain}/rabbitmq;100:101;3
/etc/ssl/private/${domain}/valkey;999:1000;2
EOL
