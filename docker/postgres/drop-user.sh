#!/usr/bin/env bash
set -eu -o pipefail -o noclobber

host=localhost
port=5432
database=postgres
tls=''
user_name=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--database) database="$2"; shift 2; ;;
    -H|--host) host="$2"; shift 2 ;;
    -p|--port) port="$2"; shift 2 ;;
    -s|--schema) schema="$2"; shift 2 ;;
    -U|--user) user_name="$2"; shift 2 ;;
    -S|--tls) tls='sslmode=require'; shift ;;
    -*|--*) echo "unknown option \`$1\`"; exit 1 ;;
    *) echo 'positional args are unsupported'; exit 1 ;;
  esac
done

PGPASSWORD="${ROOT_USER_PASSWORD}" \
psql "postgresql://${ROOT_USER_NAME:-postgres}@${host}:${port}/${database}?${tls}" <<EOF
BEGIN;

REVOKE SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA "${schema}" FROM ${user_name};
REVOKE CONNECT ON DATABASE ${database} FROM ${user_name};
REVOKE USAGE ON SCHEMA "${schema}" FROM ${user_name};
DROP USER ${user_name};

COMMIT;
EOF
