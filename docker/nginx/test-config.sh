#!/usr/bin/env bash

nginx_dir=./nginx

binds=()
echo ${nginx_dir}/*.conf
for file in "${nginx_dir}"/*.conf; do
  binds+=( -v "${file}:/etc/nginx/$(basename "${file}")" )
done

docker run --rm -t -a stdout --name 'test-nginx' \
  "${binds[@]}" \
  nginx:1.29.7-alpine3.23 \
  nginx -c /etc/nginx/nginx.conf -t
