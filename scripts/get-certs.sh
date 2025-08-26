#!/usr/bin/env bash
set -eu

cetbot certonly --manual \
  --preferred-challenges dns --agree-tos --email 'antonmanannikov3@gmail.com' \
  -d '*.senioravanti.ru' -d 'senioravanti.ru' --break-my-certs \
  --server https://acme-staging-v02.api.letsencrypt.org/directory
