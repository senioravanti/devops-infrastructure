#!/usr/bin/env sh
set -u

mc ls --recursive --json "${ALIAS}" \
  | jq -r .key \
  | parallel \
    --env ALIAS,OUT \
    --line-buffer --bar -j16 \
    'mc get "${ALIAS}/{}" "${OUT}/{}"'
