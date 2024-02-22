#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSO https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/latest.deb

DEBIAN_FRONTEND=noninteractive apt-get -y install ./latest.deb
rm ./latest.deb

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  megatools

echo "[Login]" >/root/.megarc
echo "Username = ${MEGA_EMAIL}" >>/root/.megarc
echo "Password = ${MEGA_PASSWORD}" >>/root/.megarc

megatools mkdir /Root/${RENDER_EXTERNAL_HOSTNAME}
megatools ls -l /Root/${RENDER_EXTERNAL_HOSTNAME}

echo "DUMMY" >./dummy.txt

megatools put --path /Root/${RENDER_EXTERNAL_HOSTNAME}/ dummy.txt
megatools ls -l /Root/${RENDER_EXTERNAL_HOSTNAME}/

rm ./dummy.txt

megatools get --path  /Root/${RENDER_EXTERNAL_HOSTNAME}/

ls -lang
