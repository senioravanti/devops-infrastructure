#!/usr/bin/env sh
set -eu

sysctl vm.overcommit_memory=1
# https://github.com/valkey-io/valkey/blob/9.1/valkey.conf
valkey-server --requirepass "$VALKEY_PASSWORD" \
  --bind 0.0.0.0 \
  --save 300 1 --loglevel notice \
  \
  --port 6379 --tls-port 6378 \
  --tls-cert-file /etc/ssl/valkey/fullchain.pem \
  --tls-key-file /etc/ssl/valkey/privkey.pem \
  --tls-auth-clients no
