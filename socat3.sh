#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

PIPING_SERVER=https://ppng.io
# PIPING_SERVER=https://${RENDER_EXTERNAL_HOSTNAME}/piping
# PIPING_SERVER=https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust
# AUTH="-u ${BASIC_USER}:${BASIC_PASSWORD}"
AUTH=

for i in {1..5}
do
  PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
  KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

  MESSAGE="curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} >key.txt"

  curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
    -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage

  sleep 1s

  MESSAGE="curl ${AUTH} -NsS ${PIPING_SERVER}/${KEYWORD}res | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass \\\"pass:${PASSWORD}\\\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 | socat tcp4-listen:8022,bind=127.0.0.1 - | stdbuf -i0 -o0 openssl aes-256-ctr -pass \\\"pass:${PASSWORD}\\\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 | curl ${AUTH} -m 3600 -NsST - ${PIPING_SERVER}/${KEYWORD}req"

  curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
    -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage

  sleep 1s

  MESSAGE="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p 8022 127.0.0.1 -i ./key.txt"

  curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
    -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage
  
  curl ${AUTH} -sSN ${PIPING_SERVER}/${KEYWORD}req \
   | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
   | socat tcp4:127.0.0.1:${TARGET_PORT} - \
   | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
   | curl ${AUTH} -m 300 -sSNT - ${PIPING_SERVER}/${KEYWORD}res
done
