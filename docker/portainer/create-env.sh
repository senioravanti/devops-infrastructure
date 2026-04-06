#!/usr/bin/env bash
# https://gist.github.com/deviantony/62c009b41bde5e078b1a7de9f11f5e55
PORTAINER_PASSWORD=$(openssl rand -base64 16 | tr -d '=' | tr '+/' '-_')
HASHED_PORTAINER_PASSWORD=$(docker run --rm httpd:2.4-alpine \
  htpasswd -nbB admin "$PORTAINER_PASSWORD" | \
  cut -d ":" -f 2 | sed 's/\$/\$\$/g')
cat <<EOF >> "${CONFIG_PATH:-./.env}"
# $PORTAINER_PASSWORD
PORTAINER_PASSWORD=$HASHED_PORTAINER_PASSWORD
EOF
