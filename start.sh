#!/bin/bash

set -x

# apt

apt-get -qq update

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  build-essential \
  curl \
  distcc \
  gcc-x86-64-linux-gnu \
  iproute2 \
  >/dev/null

# apache setting

a2dissite -q 000-default.conf

mkdir -p /var/www/html/auth

curl -sSL -o /var/www/html/auth/distccd.php https://github.com/tshr20180821/render-10/raw/main/distccd.php

chown www-data:www-data /var/www/html/auth -R

echo '<HTML />' >/var/www/html/index.html

{ \
  echo 'User-agent: *'; \
  echo 'Disallow: /'; \
} >/var/www/html/robots.txt

a2enmod \
 authz_groupfile \
 proxy \
 proxy_http

curl -sSL -o /etc/apache2/sites-enabled/apache.conf https://github.com/tshr20180821/render-10/raw/main/apache.conf

htpasswd -c -b /var/www/html/.htpasswd "${BASIC_USER}" "${BASIC_PASSWORD}"
chmod 644 /var/www/html/.htpasswd
. /etc/apache2/envvars >/dev/null 2>&1

# 12h
for i in {1..72}; do \
  for j in {1..10}; do sleep 60s && echo "${i} ${j}"; done \
   && ss -anpt \
   && ps aux \
   && curl -sS -A "keep instance" -u "${BASIC_USER}":"${BASIC_PASSWORD}" https://"${RENDER_EXTERNAL_HOSTNAME}"/; \
done &

# distccd

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=$(($(nproc)/2)) --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180

# sshd

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  less \
  openssh-server \
  socat \
  sudo \
  vim \

ROOT_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
SSH_USER=$(tr -dc 'a-z' </dev/urandom | fold -w 8 | head -n 1)
SSH_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

mkdir /var/run/sshd
echo "root:${ROOT_PASSWORD}" | chpasswd
cat /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
cat /etc/ssh/sshd_config

sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

export NOTVISIBLE='in users profile'
echo 'export VISIBLE=now' >> /etc/profile

useradd -m ${SSH_USER}
echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
usermod -aG sudo ${SSH_USER}
chsh -s /bin/bash ${SSH_USER}

/usr/sbin/sshd -4Dp 8022 -o "ListenAddress 127.0.0.1" &

curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

sleep 3s

socat "exec:curl -u \"${BASIC_USER}\":\"${BASIC_PASSWORD}\" -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req | openssl aes-256-cbc -d -k ${PIPING_PASSWORD}!!exec:openssl aes-256-cbc -k ${PIPING_PASSWORD} | curl -u \"${BASIC_USER}\":\"${BASIC_PASSWORD}\" -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  tcp:127.0.0.1:8022 &

# socat -d tcp-listen:8022,bind=127.0.0.1,reuseaddr,fork \
#   "exec:curl -u \"${BASIC_USER}\":\"${BASIC_PASSWORD}\" -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res | openssl aes-256-cbc -d -k ${PIPING_PASSWORD}!!exec:openssl aes-256-cbc -k ${PIPING_PASSWORD} | curl -u \"${BASIC_USER}\":\"${BASIC_PASSWORD}\" -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req"

# apache start

exec /usr/sbin/apache2 -DFOREGROUND
