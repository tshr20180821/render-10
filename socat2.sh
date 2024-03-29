#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# PIPING_SERVER=https://ppng.io
# PIPING_SERVER=${PIPING_SERVER_SPARE}
CURL_OPT=
# PIPING_SERVER=https://${RENDER_EXTERNAL_HOSTNAME}/piping
# PIPING_SERVER=https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust
# CURL_OPT="-u ${BASIC_USER}:${BASIC_PASSWORD} --http1.1"

PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

URL_RES=${PIPING_SERVER}/${KEYWORD}res
URL_REQ=${PIPING_SERVER}/${KEYWORD}req
if [ ! -z "${X_GD_APIKEY}" ]; then
  URL_RES=$(curl -sS "https://xgd.io/V1/shorten?url=$(echo ${PIPING_SERVER}/${KEYWORD}res | jq -Rr @uri)&key=${X_GD_APIKEY}&analytics=false" | jq '.shorturl')
  URL_REQ=$(curl -sS "https://xgd.io/V1/shorten?url=$(echo ${PIPING_SERVER}/${KEYWORD}req | jq -Rr @uri)&key=${X_GD_APIKEY}&analytics=false" | jq '.shorturl')
fi

{ \
  echo "#!/bin/sh";
  echo "curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} >key.txt"; \
  echo "curl ${CURL_OPT} -NsSL ${URL_RES} | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass \"pass:${PASSWORD}\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 | socat tcp4-listen:8022,bind=127.0.0.1 - | stdbuf -i0 -o0 openssl aes-256-ctr -pass \"pass:${PASSWORD}\" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 | curl ${CURL_OPT} -m 3600 -NsSLT - ${URL_REQ} &"; \
  echo "echo ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p 8022 127.0.0.1 -i ./key.txt"; \
} >/var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}_2.txt

MESSAGE="curl -fsSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}_2.txt | sh"

curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
  -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage >/dev/null

curl ${CURL_OPT} -sSN ${PIPING_SERVER}/${KEYWORD}req \
  | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | socat - tcp4:127.0.0.1:${TARGET_PORT} \
  | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | curl ${CURL_OPT} -m 300 -sSNT - ${PIPING_SERVER}/${KEYWORD}res &

expect -c "
set timeout 5
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p ${TARGET_PORT} 127.0.0.1 -i /var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}
interact
expect \"$\"
send \"ssh -fL 13632:127.0.0.1:3632 127.0.0.1 \n\"
"
