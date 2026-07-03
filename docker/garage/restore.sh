#!/usr/bin/env bash
set -u

: "${ALIAS:?is not set}"
cd "${IN}" || exit 1

find . -type f -print \
  | parallel --env ALIAS -j$(nproc --all) '
    path={}
    relpath="${path#./}"
    bucket="${relpath%%/*}"
    echo "uploading \`${relpath}\` file"
    mc mb --ignore-existing "${ALIAS}/${bucket}"
    mc put "${path}" "${ALIAS}/${relpath}"
  '
