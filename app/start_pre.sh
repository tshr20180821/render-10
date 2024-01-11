#!/bin/bash

set -x

apt-get -qq update
apt-get -q install -y curl iproute2 >/dev/null

curl -sSL -H 'Cache-Control: no-cache' -o /app/start.sh https://raw.githubusercontent.com/tshr20180821/render-10/main/app/start.sh?$(date +%s)
cat /app/start.sh
chmod +x /app/start.sh
/app/start.sh &
