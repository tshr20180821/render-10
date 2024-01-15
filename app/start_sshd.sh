#!/bin/bash

set -x

DEBIAN_FRONTEND=noninteractive apt-get -q install -y socat ssh

curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-07/main/app/hpnsshd
chmod +x ./hpnsshd

mkdir -p ./.ssh
chmod 700 ./.ssh

ssh-keygen -t rsa -N '' -f ./.ssh/ssh_host_rsa_key

cat << EOF >/app/hpnsshd_config
AddressFamily inet
ListenAddress 127.0.0.1:10022
Protocol 2
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
HostKey /app/.ssh/ssh_host_rsa_key
AuthorizedKeysFile /app/.ssh/ssh_host_rsa_key.pub
X11Forwarding no
PrintMotd no
LogLevel VERBOSE
AcceptEnv LANG LC_*
PidFile /tmp/hpnsshd.pid
ClientAliveInterval 120
ClientAliveCountMax 3
Compression no
EOF

useradd --system --shell /usr/sbin/nologin --home=/run/hpnsshd hpnsshd
mkdir /var/empty

# /app/hpnsshd -4Dp 10022 -h /app/.ssh/ssh_host_rsa_key -f /app/hpnsshd_config &
/app/hpnsshd -4De -f /app/hpnsshd_config &
cp ./.ssh/ssh_host_rsa_key.pub /usr/local/apache2/htdocs/auth/ssh_host_rsa_key.pub.txt

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

export KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

echo -n ${KEYWORD} >/usr/local/apache2/htdocs/auth/keyword.txt

echo -n ${PIPING_SERVER} >/usr/local/apache2/htdocs/auth/piping_server.txt

# socat -v -ddd "exec:./piping-duplex ${KEYWORD}sshd_request ${KEYWORD}sshd_response" tcp:127.0.0.1:10022 &

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  build-essential \
  distcc \
  gcc-x86-64-linux-gnu

DISTCCD_LOG_FILE=/usr/local/apache2/htdocs/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

# /usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=4 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180 --nice=10
/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=4 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon  --allow-private --job-lifetime=180 --nice=10 &

curl -sSLO https://github.com/nwtgck/go-piping-tunnel/releases/download/v0.10.1/piping-tunnel-0.10.1-linux-amd64.deb
dpkg -i ./piping-tunnel-0.10.1-linux-amd64.deb

whereis piping-tunnel
piping-tunnel server -k --http-read-buf-size 80960 --http-write-buf-size 80960 -s ${PIPING_SERVER}  -p 3632 --yamux ${KEYWORD}req ${KEYWORD}res &
