#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# curl -sSLo dropbox.deb https://www.dropbox.com/download?dl=packages/debian/dropbox_2024.01.22_amd64.deb

# DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ./dropbox.deb
# rm dropbox.deb

# curl -sSL https://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf -
# find / -name dropboxd -print 2>/dev/null
# /usr/src/app/.dropbox-dist/dropboxd --help
# cat /tmp/dropbox_error*.txt

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  megatools

megatools --help
megatools reg --help

# curl -sSLO https://github.com/rclone/rclone/releases/download/v1.65.2/rclone-v1.65.2-linux-amd64.deb
# dpkg -i rclone-v1.65.2-linux-amd64.deb
# rm rclone-v1.65.2-linux-amd64.deb
# rclone --help

curl -sSLO https://github.com/nwtgck/go-piping-tunnel/releases/download/v0.10.2/piping-tunnel-0.10.2-linux-amd64.deb
dpkg -i piping-tunnel-0.10.2-linux-amd64.deb

# PIPING_SERVER=https://ppng.io
PIPING_SERVER="https://${RENDER_EXTERNAL_HOSTNAME}/piping"
AUTH=$(echo -n "${BASIC_USER}:${BASIC_PASSWORD}" | base64)
# AUTH=
CURL_OPT=
AUTH_HEADER=
if [ ! -z "${AUTH}" ]; then
  AUTH_HEADER=-H "Authorization: Basic ${AUTH}"
  CURL_OPT="-u ${BASIC_USER}:${BASIC_PASSWORD}"
fi
PIPING_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
# echo "PIPING_PASSWORD : ${PIPING_PASSWORD}"

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# piping-tunnel --help

echo "curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} >key.txt" >/var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.txt
echo "chmod 600 key.txt" >>/var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.txt
echo "curl ${CURL_OPT} -NsS ${PIPING_SERVER}/${KEYWORD}res | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass \"pass:${PIPING_PASSWORD}\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 | socat tcp4-listen:8022,bind=127.0.0.1 - | stdbuf -i0 -o0 openssl aes-256-ctr -pass \"pass:${PIPING_PASSWORD}\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 | curl ${CURL_OPT} -NsST - ${PIPING_SERVER}/${KEYWORD}req &" >>/var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.txt
echo "sleep 3s" >>/var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.txt
echo "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p 8022 127.0.0.1 -i ./key.txt" >>/var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.txt

MESSAGE="curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.txt >info.txt"

curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
  -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage >/dev/null

# piping-tunnel server --verbose 5 --host 127.0.0.1 --port ${TARGET_PORT} --server https://ppng.io --cipher-type=openssl-aes-256-ctr --pbkdf2='{"iter":1000,"hash":"sha256"}' --symmetric --pass ${PIPING_PASSWORD} ${KEYWORD}req ${KEYWORD}res
piping-tunnel server --host 127.0.0.1 --port ${TARGET_PORT} ${AUTH_HEADER} \
  --symmetric --cipher-type=openssl-aes-256-ctr --pbkdf2='{"iter":1000,"hash":"sha256"}' --pass ${PIPING_PASSWORD} \
  ${KEYWORD}req ${KEYWORD}res
