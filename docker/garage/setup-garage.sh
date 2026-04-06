#!/usr/bin/env bash
set -u

env_file="${ENV_FILE:-./.env.garage}"
node_capacity="${NODE_CAPACITY:-1G}"
tmp_file="/tmp/$(uuidgen).txt"
key_name="${KEY_NAME:-root_key}"

garage() {
  local container_name="$1"; shift
  docker exec -it "${container_name}" /garage "$@" 
}

if ! docker ps --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"; then
  echo 'garage container does not exist'
  exit 1
fi

if [ ! -f "${env_file}" ]; then
  touch "${env_file}"
else
  : > "${env_file}"
fi

awk_command="$(cat << 'EOF'
/^ID[ \t]+Hostname/ { IS_HEADER = 1; next }
IS_HEADER && NF > 0 { print $1 }
EOF
)"
ids="$(garage "${CONTAINER_NAME}" status | awk "${awk_command}")"

i=1
for id in "${ids}"; do
  garage "${CONTAINER_NAME}" layout assign -z "dc${i}" -c "${node_capacity}" "${id}"
  i=$((i + 1))
done
garage "${CONTAINER_NAME}" layout apply --version 1
garage "${CONTAINER_NAME}" key create "${key_name}" | tee "${tmp_file}"
garage "${CONTAINER_NAME}" key allow --create-bucket "${key_name}"
cat <<EOF >> "${env_file}"
ACCESS_KEY=$(grep 'Key ID:' "${tmp_file}" | awk '{ print $3 }')
SECRET_KEY=$(grep 'Secret key:' "${tmp_file}" | awk '{ print $3 }')
EOF
rm "$tmp_file"
