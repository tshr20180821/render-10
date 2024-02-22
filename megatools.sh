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

# curl -sSLO https://github.com/rclone/rclone/releases/download/v1.65.2/rclone-v1.65.2-linux-amd64.deb
# dpkg -i rclone-v1.65.2-linux-amd64.deb
# rm rclone-v1.65.2-linux-amd64.deb
# rclone --help

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  megatools

echo "[Login]" >/root/.megarc
echo "Username = ${MEGA_EMAIL}" >>/root/.megarc
echo "Password = ${MEGA_PASSWORD}" >>/root/.megarc

megatools --help
megatools reg --help
megatools ls --help
megatools df --help
megatools df
megatools ls
