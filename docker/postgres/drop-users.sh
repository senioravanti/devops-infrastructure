#!/usr/bin/env bash
set -eu 

clear
while IFS="," read -r schema user_name; do
  # Должны быть заданы переменные среды ROOT_USER_NAME & ROOT_USER_PASSWORD
  ./postgres/drop-user.sh \
    -H "${HOST:-localhost}" -p "${PORT:-5432}" \
    -d "${DATABASE:-postgres}" -s "${schema}" -U "${user_name}"
done < "$1"
