#!/usr/bin/env sh
set -eu

sysctl vm.overcommit_memory=1

redis-server --port 0 --tls-port 6379 \
  --requirepass "$REDIS_PASSWORD" \
  --save 300 1 --loglevel notice \
  --tls-cert-file /etc/ssl/redis/fullchain.pem \
  --tls-key-file /etc/ssl/redis/privkey.pem \
  --tls-ca-cert-file /etc/ssl/certs/isrgrootx1.pem