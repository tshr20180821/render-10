#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSLO https://github.com/nwtgck/go-piping-tunnel/releases/download/v0.10.2/piping-tunnel-0.10.2-linux-amd64.deb
dpkg -i piping-tunnel-0.10.2-linux-amd64.deb

PIPING_SERVER=https://ppng.io
PIPING_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# piping-tunnel --help

# piping-tunnel server --verbose 5 --host 127.0.0.1 --port ${TARGET_PORT} --server https://ppng.io --cipher-type=openssl-aes-256-ctr --pbkdf2='{"iter":1000,"hash":"sha256"}' --symmetric --pass ${PIPING_PASSWORD} ${KEYWORD}req ${KEYWORD}res
piping-tunnel server --host 127.0.0.1 --port ${TARGET_PORT} \
  --symmetric --cipher-type=openpgp   --pass ${PIPING_PASSWORD} \
  ${KEYWORD}req ${KEYWORD}res
