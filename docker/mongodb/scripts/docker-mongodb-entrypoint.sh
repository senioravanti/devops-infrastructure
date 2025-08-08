#!/usr/bin/env bash
set -eu

mongod --auth --tlsMode preferTLS \
  --tlsCertificateKeyFile /etc/ssl/mongodb/cert.pem \
  --tlsCAFile /etc/ssl/mongodb/fullchain.pem \
  --tlsAllowConnectionsWithoutCertificates