#!/usr/bin/env bash
set -e

ENV_FILES=(
	"./.env"
)

function create_env_file() {
  case "$1" in
  "${ENV_FILES[0]}") 
  cat <<-EOL > "${ENV_FILES[0]}"
		DOMAIN=senioravanti.ru

		# vault
		VAULT_SERVER_EXTERNAL_PORT=8200
		VAULT_CLIENT_EXTERNAL_PORT=8201
		VAULT_SECRET_DIR=./vault/secrets
		VAULT_SCRIPTS_DIR=./vault/scripts
		VAULT_BASE_URI=http://vault:8200/v1/cubbyhole

		# ssl
		SSL_ROOT_CERT_PATH='/etc/ssl/certs/isrgrootx1.pem'
		SSL_CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
		SSL_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
		SSL_POSTGRES_CERT_PATH="/etc/ssl/private/${DOMAIN}/postgres/fullchain.pem"
		SSL_POSTGRES_KEY_PATH="/etc/ssl/private/${DOMAIN}/postgres/privkey.pem"

		# postgres
		POSTGRES_TAG=17.5-alpine3.22
		POSTGRES_BOOTSTRAP_PASSWORD=bootstrap_password
		POSTGRES_EXTERNAL_PORT=5432

		# minio
		MINIO_ROOT_USER=bootcups
		MINIO_BACKEND_EXTERNAL_PORT=9090
		MINIO_FRONTENT_EXTERNAL_PORT=9091

		# gitlab runner
		GITLAB_VERSION=18.2.0
		RUNNER_TOKEN=''
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