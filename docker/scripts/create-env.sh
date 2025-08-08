#!/usr/bin/env bash
set -eu

ENV_FILES=(
	'./.env'
	'./environment/.env.minio'
	'./environment/.env.mongodb'
	'./environment/.env.redis'
)

gen_url_safe_password() {
	local PASSWORD_LENGTH="$1"
	openssl rand -base64 "$PASSWORD_LENGTH" | tr '+/' '-_' | tr -d '='
}

create_env_file() {
  case "$1" in
  "${ENV_FILES[0]}")
	DOMAIN=senioravanti.ru
  cat <<-EOL > "${ENV_FILES[0]}"
		# ssl
		SSL_LETSENCRYPT_CA_PATH='/etc/ssl/certs/isrgrootx1.pem'		
		SSL_LETSENCRYPT_PATH="/etc/letsencrypt/live/${DOMAIN}"
		SSL_PRIVATE_PATH="/etc/ssl/private/${DOMAIN}"

		# postgres
		POSTGRES_TAG=17.5-alpine3.22
		POSTGRES_BOOTSTRAP_PASSWORD=bootstrap_password
		POSTGRES_EXTERNAL_PORT=5432

		# mongodb
		MONGO_VERSION=8.0.12

		# redis
		REDIS_VERSION=8.2.0
EOL
	;;
	"${ENV_FILES[1]}")
  cat <<-EOL > "${ENV_FILES[1]}"
		MINIO_ROOT_USER=minioadmin
		MINIO_ROOT_PASSWORD='$(gen_url_safe_password 24)'
EOL
	;;
	"${ENV_FILES[2]}")
  cat <<-EOL > "${ENV_FILES[2]}"
		MONGO_INITDB_ROOT_USERNAME=mongoadmin
		MONGO_INITDB_ROOT_PASSWORD='$(gen_url_safe_password 24)'
		MONGO_INITDB_DATABASE=admin
EOL
	;;
	"${ENV_FILES[3]}")
  cat <<-EOL > "${ENV_FILES[3]}"
		REDIS_PASSWORD='$(gen_url_safe_password 24)'
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