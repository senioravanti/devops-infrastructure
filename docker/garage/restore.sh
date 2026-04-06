#!/usr/bin/env bash

cd "$OUT" || exit 1

find . -type f -print | while IFS= read -r filepath; do
  RELPATH="${filepath#./}"
  BUCKET="${RELPATH%%/*}"
  echo "uploading \`$RELPATH\` file"
  mc mb --ignore-existing "$ALIAS/$BUCKET" > /dev/null
  mc put "$filepath" "$ALIAS/$RELPATH" > /dev/null &
done
