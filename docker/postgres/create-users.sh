#!/usr/bin/env bash
set -eu 

clear
while IFS=',' read -r schema user_name password; do
  password=${password#[$'"\'']}
  password=${password%[$'"\'']}
  # Должны быть заданы переменные среды ROOT_USER_NAME & ROOT_USER_PASSWORD
  NEW_USER_PASSWORD="${password}" \
  ./postgres/create-user.sh \
    -H "${HOST:-localhost}" -p "${PORT:-5432}" \
    -d "${DATABASE:-postgres}" -s "${schema}" -U "${user_name}"
done < "$1"
