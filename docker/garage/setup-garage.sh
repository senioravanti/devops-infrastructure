#!/usr/bin/env sh

set -u

garage() {
  local CONTAINER_NAME="$1"; shift
  docker exec -it "$CONTAINER_NAME" /garage $@ 
}

if [ ! -f './garage.toml' ]; then
  ./create-config.sh
fi

GARAGE_CONTAINER_NAME=${CONTAINER_NAME:-some-garage}
if [ ! -f './.env.garage' ]; then
  echo "CONTAINER_NAME=$GARAGE_CONTAINER_NAME" > './.env.garage'
fi

if ! docker ps --format '{{.Names}}' | grep -q "$GARAGE_CONTAINER_NAME"; then
  echo 'garage container does not exist'
  exit 1
fi

AWK=$(cat << 'EOF'
/^ID[ \t]+Hostname/ { IS_HEADER = 1; next }
IS_HEADER && NF > 0 { print $1 }
EOF
)
IDS=$(garage $GARAGE_CONTAINER_NAME status | awk "$AWK")

I=1
for ID in $IDS; do
  garage $GARAGE_CONTAINER_NAME layout assign -z "dc$I" -c 1G "$ID"
  I=$((I + 1))
done
garage $GARAGE_CONTAINER_NAME layout apply --version 1

GARAGE_KEY_NAME=${KEY_NAME:-root-key}
TMP_FILE="/tmp/$(uuidgen).txt"
garage $GARAGE_CONTAINER_NAME key create "$GARAGE_KEY_NAME"  > "$TMP_FILE"
garage $GARAGE_CONTAINER_NAME key allow --create-bucket "$GARAGE_KEY_NAME"

cat <<EOF >> ./.env.garage
ACCESS_KEY=$(grep 'Key ID:' "$TMP_FILE" | awk '{ print $3 }')
SECRET_KEY=$(grep 'Secret key:' "$TMP_FILE" | awk '{ print $3 }')
EOF
