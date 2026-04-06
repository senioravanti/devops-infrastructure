#!/usr/bin/env sh
set -eu

sysctl vm.overcommit_memory=1
valkey-server --requirepass "$VALKEY_PASSWORD" \
  --bind 0.0.0.0 \
  --save 300 1 --loglevel notice \
  # --tls-port 6379 \
  # \
  # --tls-cert-file /etc/ssl/valkey/fullchain.pem \
  # --tls-key-file /etc/ssl/valkey/privkey.pem \
  # --tls-ca-cert-file /etc/ssl/certs/isrgrootx1.pem \
  # --tls-auth-clients no
