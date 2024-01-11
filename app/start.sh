#!/bin/bash

set -x

curl -sSL -H 'Cache-Control: no-cache' -o /app/start_distccd.sh https://raw.githubusercontent.com/tshr20180821/render-10/main/app/start_distccd.sh?$(date +%s)
cat /app/start_distccd.sh
chmod +x /app/start_distccd.sh
sleep 10s && /app/start_distccd.sh &

# a2enmod authz_groupfile

find / -name httpd.conf -print

apachectl -DFOREGROUND