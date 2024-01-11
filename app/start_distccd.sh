#!/bin/bash

set -x

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends distcc socat >/dev/null

# touch /var/www/html/auth/distccd_log.txt
# chmod 666 /var/www/html/auth/distccd_log.txt

# /usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=1 --log-level=debug --log-file=/var/www/html/auth/distccd_log.txt --daemon
/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=1 --log-level=debug --log-stderr --daemon --stats --stats-port=3633

sleep 10s
ss -anpt

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

export KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

socat -ddd "exec:./piping-duplex ${KEYWORD}distccd_request ${KEYWORD}distccd_response" tcp:127.0.0.1:3632 &
