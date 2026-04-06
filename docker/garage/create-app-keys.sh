#!/usr/bin/env bash
set -eu

garage() {
  local container_name="$1"; shift
  docker exec -it "${container_name}" /garage "$@" 
}

if ! docker ps --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"; then
  echo 'garage container does not exist'
  exit 1
fi

garage "${CONTAINER_NAME}" key create "${KEY_NAME}"
if ! garage "${CONTAINER_NAME}" bucket list | grep -qw "${BUCKET_NAME}"; then
  echo "creating bucket \`${BUCKET_NAME}\`"
  bucket_id="$(garage "${CONTAINER_NAME}" bucket create "${BUCKET_NAME}" \
    | grep -w "${BUCKET_NAME}" | awk '{ print $1 }')"
  garage "${CONTAINER_NAME}" bucket alias "${bucket_id}" "${BUCKET_NAME}"
fi
garage "${CONTAINER_NAME}" bucket allow \
  --read --write --owner "${BUCKET_NAME}" \
  --key "${KEY_NAME}"
