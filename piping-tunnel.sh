#!/bin/bash

set -x

AUTH=$(echo -n "${BASIC_USER}:${BASIC_PASSWORD}" | base64)
PIPING_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "PIPING_PASSWORD : ${PIPING_PASSWORD}"

while true
do
  echo start piping-tunnel
  piping-tunnel server --pass ${PIPING_PASSWORD} --port ${TARGET_PORT} --symmetric --header "Authorization: Basic ${AUTH}" --server https://${RENDER_EXTERNAL_HOSTNAME}/piping req res
  echo finish piping-tunnel
done
