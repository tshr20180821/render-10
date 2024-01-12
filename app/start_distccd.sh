#!/bin/bash

set -x

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  build-essential \
  distcc \
  gcc-x86-64-linux-gnu \
  socat \
  >/dev/null

ls -lang /usr/lib/distcc >/usr/local/apache2/htdocs/auth/ls_usr_lib_distcc.txt

DISTCCD_LOG_FILE=/usr/local/apache2/htdocs/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

# /usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=1 --log-level=debug --log-stderr --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180 --nice=10
/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=1 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180 --nice=10

sleep 10s
ss -anpt

curl -v http://127.0.0.1:3633/

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

export KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

echo -n ${KEYWORD} >/usr/local/apache2/htdocs/auth/keyword.txt
# export PIPING_SERVER=https://ppng.io
export PIPING_SERVER=https://piping.nwtgck.repl.co
echo -n ${PIPING_SERVER} >/usr/local/apache2/htdocs/auth/piping_server.txt

socat -ddd "exec:./piping-duplex ${KEYWORD}distccd_request ${KEYWORD}distccd_response" tcp:127.0.0.1:3632 &
