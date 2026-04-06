#!/usr/bin/env bash
set -u

FILES=$(mc ls --recursive "$ALIAS" | awk '{ print $NF }')
for FILE in $FILES; do
  mc get "$ALIAS/$FILE" "$OUT/$FILE" &
done
