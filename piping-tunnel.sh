#!/bin/bash

set -x

AUTH=$(echo -n "${BASIC_USER}:${BASIC_PASSWORD}" | base64)
PIPING_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "PIPING_PASSWORD : ${PIPING_PASSWORD}"

for i in {1..2}
do
  # echo start piping-tunnel ${i}
  piping-tunnel server --verbose 5 --host 127.0.0.1 --pass ${PIPING_PASSWORD} --port ${TARGET_PORT} --symmetric --server https://ppng.io/ ${PIPING_PASSWORD}req ${PIPING_PASSWORD}res

  # echo start piping-tunnel ${i} ${PIPING_SERVER}
  # piping-tunnel server --verbose 5 --host 127.0.0.1 --pass ${PIPING_PASSWORD} --port ${TARGET_PORT} --symmetric --server ${PIPING_SERVER} req res

  # echo start piping-tunnel ${i} https://${RENDER_EXTERNAL_HOSTNAME}/piping
  # piping-tunnel server --verbose 5 --host 127.0.0.1 --pass ${PIPING_PASSWORD} --port ${TARGET_PORT} --symmetric --header "Authorization: Basic ${AUTH}" --server https://${RENDER_EXTERNAL_HOSTNAME}/piping req res

  curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} -d 'dummy' https://${RENDER_EXTERNAL_HOSTNAME}/piping/req
done
