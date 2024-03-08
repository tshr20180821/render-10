#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

PIPING_SERVER=https://ppng.io
CURL_OPT="-m 3600 -sSN"

PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

# distcc server
curl ${CURL_OPT} ${PIPING_SERVER}/${KEYWORD}req \
  | stdbuf -i0 -o0 openssl aes-128-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1 -md sha256 \
  | socat - tcp4:127.0.0.1:${TARGET_PORT} \
  | stdbuf -i0 -o0 openssl aes-128-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1 -md sha256 \
  | curl ${CURL_OPT} -T - ${PIPING_SERVER}/${KEYWORD}res &

# distcc client
curl ${CURL_OPT} ${PIPING_SERVER}/${KEYWORD}res \
  | stdbuf -i0 -o0 openssl aes-128-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1 -md sha256 \
  | socat tcp4-listen:9022,bind=127.0.0.1 - \
  | stdbuf -i0 -o0 openssl aes-128-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1 -md sha256 \
  | curl ${CURL_OPT} -T - ${PIPING_SERVER}/${KEYWORD}req &

sleep 3s

ssh --help

cat /etc/ssh/ssh_config

ssh -v -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o ServerAliveInterval=60 -o ServerAliveCountMax=60 \
  -p 9022 \
  -i /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} \
  -4fNL 13632:127.0.0.1:3632 ${SSH_USER}@127.0.0.1 &

# memcached

DEBIAN_FRONTEND=noninteractive apt-get install -y libevent-dev >/dev/null 2>&1

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g' >/tmp/cflags_option
cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp
curl -sSO https://memcached.org/files/memcached-1.6.22.tar.gz
tar xf memcached-1.6.22.tar.gz

export DISTCC_HOSTS="127.0.0.1:13632/4,lzo,cpp"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export DISTCC_FALLBACK=0
export DISTCC_IO_TIMEOUT=600

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time HOME=/tmp MAKEFLAGS="CC=distcc-pump\ distcc\ gcc" make -j4

popd
popd

ls -lang /var/www/html/auth/
