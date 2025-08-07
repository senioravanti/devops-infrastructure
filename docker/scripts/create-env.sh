#!/usr/bin/env bash
set -eu

ENV_FILES=(
	'./.env'
	'./environment/.env.minio'
	'./environment/.env.mongodb'
)

create_env_file() {
  case "$1" in
  "${ENV_FILES[0]}")
	DOMAIN=senioravanti.ru
  cat <<-EOL > "${ENV_FILES[0]}"
		# ssl
		SSL_ROOT_CERT_PATH='/etc/ssl/certs/isrgrootx1.pem'
		
		SSL_CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
		SSL_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

		SSL_POSTGRES_CERT_PATH="/etc/ssl/private/${DOMAIN}/postgres/fullchain.pem"
		SSL_POSTGRES_KEY_PATH="/etc/ssl/private/${DOMAIN}/postgres/privkey.pem"

		SSL_MONGODB_CERT_PATH="/etc/ssl/private/${DOMAIN}/mongodb/cert.pem"

		# postgres
		POSTGRES_TAG=17.5-alpine3.22
		POSTGRES_BOOTSTRAP_PASSWORD=bootstrap_password
		POSTGRES_EXTERNAL_PORT=5432

		# mongodb
		MONGODB_VERSION=8.0.12
EOL
	;;
	"${ENV_FILES[1]}")
  cat <<-EOL > "${ENV_FILES[1]}"
		MINIO_ROOT_USER=minioadmin
		MINIO_ROOT_PASSWORD=\'$(openssl rand -base64 24)\'
EOL
	;;
	"${ENV_FILES[2]}")
  cat <<-EOL > "${ENV_FILES[2]}"
		MONGO_INITDB_ROOT_USERNAME=mongoadmin
		MONGO_INITDB_ROOT_PASSWORD=\'$(openssl rand -base64 24)\'
EOL
	;;
  *) echo 'unknown file name' ;;
  esac
}

clear
for IT in "${ENV_FILES[@]}"; do
  if [ ! -f "$IT" ]; then
    echo "creating \`$IT\` ..."
    create_env_file "$IT"
  fi
done