#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

PIPING_SERVER="https://${RENDER_EXTERNAL_HOSTNAME}/piping"
PIPING_SERVER=$(echo ${PIPING_SERVER} | sed 's/:/\\:/')
AUTH="-u ${BASIC_USER}\:${BASIC_PASSWORD}"
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "KEYWORD : ${KEYWORD}"

{ \
  echo "pwd"; \
  echo "curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} >key.txt"; \
  echo "chmod 600 key.txt"; \
  echo "set +H"; \
  echo "socat -4 tcp4-listen:8022,bind=127.0.0.1 'exec:curl ${AUTH} -NsS ${PIPING_SERVER}/${KEYWORD}res!!exec:curl ${AUTH} -NsST - ${PIPING_SERVER}/${KEYWORD}req' &"; \
  echo "set -H"; \
  echo "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p 8022 127.0.0.1 -i ./key.txt"; \
} >MESSAGE.txt

MESSAGE=$(cat MESSAGE.txt | base64 -w 0)
rm MESSAGE.txt

curl -sS -X POST -H "Authorization: Bearer ${SLACK_TOKEN}" -H "Content-Type: application/json" \
  -d "{\"channel\":\"${SLACK_CHANNEL}\",\"text\":\"${MESSAGE}\"}" https://slack.com/api/chat.postMessage

for i in {1..2}
do
  echo start socat ${i}
  # NG
  socat "exec:curl ${AUTH}  -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -m 3600 ${AUTH} -NsS --data-binary @- ${PIPING_SERVER}/${KEYWORD}res" \
    tcp4:127.0.0.1:${TARGET_PORT}
  # OK
  # socat -4 "exec:curl -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -m 3600 -NsST - ${PIPING_SERVER}/${KEYWORD}res" \
  #   tcp4:127.0.0.1:${TARGET_PORT}
done
