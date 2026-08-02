#!/usr/bin/env sh
set -u

: "${1:?alias is not set}"
: "${2:?out dir is not set}"
als="$1"
out="$2"
mc ls --recursive --json "${als}" \
  | jq -r .key \
  | tr -d '\r' \
  | parallel \
    --line-buffer --bar -j$(nproc --all) \
    mc get "${als}/{}" "${out}/{}"
