#!/bin/bash

set -x

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.deb
dpkg -i piping-duplex-0.3.0-release-trigger2-linux-amd64.deb

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

piping-duplex --help

for i in {1..2}
do
  socat "exec:piping-duplex -c -s https\://ppng.io ${KEYWORD}res ${KEYWORD}req" tcp:127.0.0.1:8022
done
