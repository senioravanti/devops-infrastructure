#!/usr/bin/env sh
set -u

: "${OUT:?dir is not set}"

mc ls --recursive --json "${ALIAS}" \
  | jq -r .key \
  | parallel \
    --env ALIAS,OUT \
    --line-buffer --bar -j$(nproc --all) \
    'mc get "${ALIAS}/{}" "${OUT}/{}"'
