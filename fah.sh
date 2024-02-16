#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSO https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.21_amd64.deb

dpkg -i fahclient_7.6.21_amd64.deb

find / -name fahclient -print 2>/dev/null

fahclient --help
