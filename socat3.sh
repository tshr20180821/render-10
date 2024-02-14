#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

socat -h

PIPING_SERVER=$(echo ${PIPING_SERVER} | sed 's/:/\\:/')
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "KEYWORD : ${KEYWORD}"

{ \
  echo "pwd"; \
  echo "curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} >key.txt"; \
  echo "chmod 600 key.txt"; \
  echo "set +H"; \
  echo "socat -4 tcp4-listen:8022,bind=127.0.0.1 'exec:curl -NsS ${PIPING_SERVER}/${KEYWORD}res!!exec:curl -NsST - ${PIPING_SERVER}/${KEYWORD}req' &"; \
  echo "set -H"; \
  echo "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p 8022 127.0.0.1 -i ./key.txt"; \
} >MESSAGE.txt

cat MESSAGE.txt

# openssl genrsa -aes256 -out server.key 4096
openssl genrsa -out server.key 4096
openssl req -new -key server.key -x509 -days 365 -subj /CN=US/ -out server.crt
cat server.key server.crt >server.pem
chmod 600 server.key server.pem

openssl genrsa -out client.key 4096
openssl req -new -key client.key -x509 -days 365 -subj /CN=US/ -out client.crt
cat client.key client.crt >client.pem
chmod 600 client.key client.pem

ls -lang

cp ./server.pem /var/www/html/auth/
cp ./client.crt /var/www/html/auth/

socat -4 -dddd "exec:curl -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
  openssl:127.0.0.1:${TARGET_PORT},cert=/usr/src/app/client.pem,cafile=/usr/src/app/server.crt
