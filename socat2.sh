#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# socat -ddd -v -4 "exec:curl -v -k -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -v -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:${TARGET_PORT}
socat -4 "exec:curl -k -NsS https\://ppng.io/${KEYWORD}req | openssl aes-256-cbc!!exec:openssl aes-256-cbc -d | curl -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
  tcp4:127.0.0.1:${TARGET_PORT}
