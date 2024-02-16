#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSO https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.21_amd64.deb

touch /usr/share/doc/fahclient/sample-config.xml

DEBIAN_FRONTEND=noninteractive apt-get -y install ./fahclient_7.6.21_amd64.deb

find / -name FAHClient -print 2>/dev/null

FAHClient --help

FAHClient -v --user=Anonymous --team=0 --gpu=false --gui-enabled=false --cpus=$(($(nproc)/2)) --chdir=/tmp --log-to-screen=true \
  --http-addresses=127.0.0.1:7396 --command-address=127.0.0.1 --max-packet-size=small --priority=normal --verbosity=5 &
