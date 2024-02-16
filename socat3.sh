#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

MESSAGE="curl -sSN https://ppng.io/${KEYWORD}res | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass pass:${PASSWORD} -bufsize 1 -pbkdf2 -iter 1000 -md sha-256 | socat tcp4-listen:8022,bind=127.0.0.1 - | stdbuf -i0 -o0 openssl aes-256-ctr -pass pass:${PASSWORD} -bufsize 1 -pbkdf2 -iter 1000 -md sha-256 | curl -m 3600 -sSNT - https://ppng.io/${KEYWORD}req"

curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
  -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage

for i in {1..5}
do
  curl -sSN https://ppng.io/${KEYWORD}req \
   | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass pass:${PASSWORD} -bufsize 1 -pbkdf2 -iter 1000 -md sha-256 \
   | socat - tcp4:127.0.0.1:${TARGET_PORT} \
   | stdbuf -i0 -o0 openssl aes-256-ctr -pass pass:${PASSWORD} -bufsize 1 -pbkdf2 -iter 1000 -md sha-256 \
   | curl -m 3600 -sSNT - https://ppng.io/${KEYWORD}res
done
