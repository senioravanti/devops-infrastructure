#!/usr/bin/env bash
set -eu

rabbitmqctl() {
  local container_name="$1"; shift
  docker exec -it "${container_name}" rabbitmqctl "$@" 
}

if ! docker ps --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"; then
  echo 'rabbitmq container does not exist'
  exit 1
fi

rabbitmqctl "${CONTAINER_NAME}" add_user "${USER_NAME}" "${USER_PASSWORD}"

# First ".*" for configure permission on every entity
# Second ".*" for write permission on every entity
# Third ".*" for read permission on every entity
rabbitmqctl "${CONTAINER_NAME}" set_permissions -p / "${USER_NAME}" ".*" ".*" ".*"
