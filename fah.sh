#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSO https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.21_amd64.deb

touch /usr/share/doc/fahclient/sample-config.xml

DEBIAN_FRONTEND=noninteractive apt-get -y install ./fahclient_7.6.21_amd64.deb

find / -name FAHClient -print 2>/dev/null

FAHClient --help

FAHClient -v --user=Anonymous --team=0 --gpu=false --cpus=1 --chdir=/tmp &
