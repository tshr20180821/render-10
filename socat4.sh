#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# PIPING_SERVER=https://ppng.io

PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

curl -sSN ${PIPING_SERVER}/${KEYWORD}req \
  | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | socat - tcp4:127.0.0.1:${TARGET_PORT} \
  | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | curl -m 300 -sSNT - ${PIPING_SERVER}/${KEYWORD}res &

curl -NsSL ${PIPING_SERVER}/${KEYWORD}res \
  | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass \"pass:${PASSWORD}\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | socat tcp4-listen:9022,bind=127.0.0.1 - \
  | stdbuf -i0 -o0 openssl aes-256-ctr -pass \"pass:${PASSWORD}\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | curl -m 3600 -NsSLT - ${PIPING_SERVER}/${KEYWORD}req &

sleep 3s

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -p 9022 \
  -i /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} \
  -4fNL 13632:127.0.0.1:3632 ${SSH_USER}@127.0.0.1
