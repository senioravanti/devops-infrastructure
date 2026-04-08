#!/usr/bin/env bash
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
set -eu -o pipefail -o noclobber

# defaults
host=localhost
port=5432
database=postgres
schema=public
tls=''
new_user_name=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--database) database="$2"; shift 2; ;;
    -H|--host) host="$2"; shift 2 ;;
    -s|--schema) schema="$2"; shift 2 ;;
    -U|--user) new_user_name="$2"; shift 2 ;;
    -S|--tls) tls='sslmode=require'; shift ;;
    -*|--*) echo "unknown option \`$1\`"; exit 1 ;;
    *) echo 'positional args are unsupported'; exit 1 ;;
  esac
done

if [[ -z "${new_user_name}" ]]; then
  new_user_name="${database}_user"
fi

psql "postgresql://postgres:${ROOT_USER_PASSWORD}@${host}:${port}/${database}?${tls}" <<EOF
BEGIN;

CREATE USER ${new_user_name} PASSWORD '${NEW_USER_PASSWORD}';
GRANT CONNECT ON DATABASE ${database} TO ${new_user_name};

GRANT USAGE ON SCHEMA ${schema} TO ${new_user_name};
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA ${schema} TO ${new_user_name};
REVOKE DELETE, TRUNCATE ON ALL TABLES IN SCHEMA ${schema} FROM ${new_user_name};

COMMIT;
EOF
