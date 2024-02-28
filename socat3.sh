#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# PIPING_SERVER=https://ppng.io
# CURL_OPT=
PIPING_SERVER=https://${RENDER_EXTERNAL_HOSTNAME}/piping
# PIPING_SERVER=https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust
CURL_OPT="-u ${BASIC_USER}:${BASIC_PASSWORD} --http1.1"

for i in {1..2}
do
  PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
  KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

  curl ${CURL_OPT} -sSN ${PIPING_SERVER}/${KEYWORD}req \
   | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
   | socat tcp4:127.0.0.1:${TARGET_PORT} - \
   | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
   | curl ${CURL_OPT} -m 300 -sSNT - ${PIPING_SERVER}/${KEYWORD}res
done
