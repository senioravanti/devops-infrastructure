#!/usr/bin/env bash
set -u

env_file=./.env.garage
tmp_file="/tmp/$(uuidgen).txt"
key_name=root_key

capacity=1G
name="garage"
mode="docker"

POSITIONAL_ARGS=()
modes=("k8s" "docker")

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mode)
            if [[ "${modes[*]}" =~ "$2" ]]; then
              mode="$2"
              shift 2
            else
              echo "Unknown mode '$2'"
              exit 1
            fi
            ;;
        -n|--name)
            name="$2"
            shift 2
            ;;
        -c|--capacity)
            capacity="$2"
            shift 2
            ;;
        -K|--key-name)
            key_name="$2"
            shift 2
            ;;
        -E|--env-file)
            env_file="$2"
            shift 2
            ;;
        -*|--*)
            echo "Unknown option '$1'"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"

garage() {
  case "${mode}" in
    k8s)
      kubectl exec --stdin -n "${name}" garage-0 -- ./garage "$@"
      ;;
    docker)
      docker exec -i "${name}" /garage "$@" 
      ;;
  esac
}

name-validator() {
  case "${mode}" in
    k8s)
      kubectl -n "${name}" get pod "garage-0" > /dev/null 2>&1
      ;;
    docker)
      docker ps --format '{{.Names}}' | grep -q "${name}"
      ;;
  esac
}
if ! name-validator; then
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

i=1
echo "$(garage status | awk "${awk_command}")" | \
while IFS='\n' read id; do 
  garage layout assign -z "dc${i}" -c "${capacity}" "${id}"
  i=$((i + 1))
done

garage layout show
garage layout apply --version 1
garage key create "${key_name}" | tee "${tmp_file}"
garage key allow --create-bucket "${key_name}"
cat <<EOF >> "${env_file}"
ACCESS_KEY=$(grep 'Key ID:' "${tmp_file}" | awk '{ print $3 }')
SECRET_KEY=$(grep 'Secret key:' "${tmp_file}" | awk '{ print $3 }')
EOF
rm "${tmp_file}"

