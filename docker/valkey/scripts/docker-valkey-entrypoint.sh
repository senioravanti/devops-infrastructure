#!/usr/bin/env sh
set -eu

valkey-server --port 0 --tls-port 6379 \
  --requirepass "$VALKEY_PASSWORD" \
  --save 300 1 --loglevel notice \
  \
  --tls-cert-file /etc/ssl/valkey/fullchain.pem \
  --tls-key-file /etc/ssl/valkey/privkey.pem \
  --tls-ca-cert-file /etc/ssl/certs/isrgrootx1.pem \
  --tls-auth-clients no