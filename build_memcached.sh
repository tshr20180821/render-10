#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# distccd

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 16 | head -n 1)

curl -sSN https://ppng.io/${KEYWORD}req \
  | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | socat - tcp4:127.0.0.1:3632 \
  | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | curl -m 300 -sSNT - https://ppng.io/${KEYWORD}res &

curl -NsSL https://ppng.io/${KEYWORD}res \
  | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | socat tcp4-listen:13632,bind=127.0.0.1,fork,reuseaddr - \
  | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:${PASSWORD}" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | curl -m 3600 -NsSLT - https://ppng.io/${KEYWORD}req &

ss -anpt

DEBIAN_FRONTEND=noninteractive apt-get install -y libevent-dev >/dev/null 2>&1

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g' >/tmp/cflags_option
cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp
curl -sSO https://memcached.org/files/memcached-1.6.22.tar.gz
tar xf memcached-1.6.22.tar.gz

export DISTCC_HOSTS="127.0.0.1:13632/1"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export DISTCC_FALLBACK=0

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time HOME=/tmp MAKEFLAGS="CC=distcc\ gcc" make -j4

popd
popd

ls -lang /var/www/html/auth/
