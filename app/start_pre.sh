#!/bin/bash

set -x

date +'%Y-%m-%d %H:%M:%S'

apt-get -qq update
DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends curl iproute2 >/dev/null

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-10/raw/main/app/start.sh

cat ./start.sh
chmod +x ./start.sh
./start.sh