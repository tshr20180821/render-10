#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# apt

curl -sSLo /usr/local/sbin/apt-fast https://raw.githubusercontent.com/ilikenwf/apt-fast/master/apt-fast
chmod +x /usr/local/sbin/apt-fast

echo "MIRRORS=('http://deb.debian.org/debian','http://ftp.debian.org/debian,http://mirror.coganng.com/debian/,http://mirror.sg.gs/debian/,http://ossmirror.mycloud.services/debian/,http://ftp.nara.wide.ad.jp/debian/,http://ftp.kddilabs.jp/pub/debian/,http://ftp.riken.jp/Linux/debian/debian/')" >/etc/apt-fast.conf

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  aria2 \
  >/dev/null

DEBIAN_FRONTEND=noninteractive apt-fast install -y --no-install-recommends \
  build-essential \
  curl \
  distcc \
  gcc-x86-64-linux-gnu \
  iproute2 \
  openssl \
  socat

# distccd

# MARK 01
curl -sSLo /var/www/html/auth/distccd.php https://github.com/tshr20180821/render-10/raw/main/distccd.php &

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=$(($(nproc)/2)) --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180

# sshd

if [ ! -z "${PIPING_SERVER}" ]; then
  # MARK 02
  curl -sS ${PIPING_SERVER}/help &
fi

# MARK 03
DEBIAN_FRONTEND=noninteractive apt-fast install -y --no-install-recommends \
  dropbear \
  expect \
  less \
  libpam-systemd \
  openssh-server \
  sudo \
  telnetd \
  vim \
  xinetd &

echo "root:rootpassword" | chpasswd

# ROOT_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
export SSH_USER=$(tr -dc 'a-z' </dev/urandom | fold -w 1 | head -n 1)$(tr -dc 'a-z0-9' </dev/urandom | fold -w 15 | head -n 1)
export SSH_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# ls -lang /etc/ssh/sshd_config.d/

mkdir /var/run/sshd
# echo "root:${ROOT_PASSWORD}" | chpasswd

export NOTVISIBLE='in users profile'
echo 'export VISIBLE=now' >> /etc/profile
cp /etc/profile /var/www/html/auth/profile.txt

# useradd -b /home -m -s /bin/bash ${SSH_USER}
useradd -b /home -m -N -s /bin/bash ${SSH_USER}
echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
# usermod -aG users ${SSH_USER}
usermod -aG root ${SSH_USER}

mkdir -p /home/${SSH_USER}/.ssh
chmod 700 /home/${SSH_USER}/.ssh

ln -sfT /dev/stdout /var/log/telnetd.log

# MARK 01 02 03
wait

expect --help
# /usr/sbin/telnetd --help

cat << EOF >/etc/xinetd.d/telnet
service telnet
{
  flags           = REUSE
  socket_type     = stream
  wait            = no
  user            = root
  server          = /usr/sbin/telnetd
  log_on_success  = HOST PID USERID
  log_on_failure  = HOST USERID
  disable         = no
  bind            = 127.0.0.1
  only_from       = 127.0.0.1
  log_type        = FILE /var/log/telnetd.log
}
EOF

cat /etc/xinetd.d/telnet

/etc/init.d/xinetd restart

ssh-keygen -f /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} -t rsa -N ""

sed -i 's/root/'${SSH_USER}'/' /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub
cat /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub >>/etc/dropbear/authorized_keys
cat /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub >>/home/${SSH_USER}/.ssh/authorized_keys

chown -R ${SSH_USER}:users /home/${SSH_USER}

echo "PS1=\"user@${RENDER_EXTERNAL_HOSTNAME//.onrender.com/}:\\w\\$ \"" >>/home/${SSH_USER}/.bashrc
cat /home/${SSH_USER}/.bashrc

cp /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} /var/www/html/auth/
chmod 666 /var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}

dropbear --help
dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
ls -lang /etc/dropbear/
# /usr/sbin/dropbear -Eswp 127.0.0.1:8022 -p 127.0.0.1:9022 -p 127.0.0.1:10022
/usr/sbin/dropbear -Eswp 127.0.0.1:8022

# curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
# ./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

# curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
# ./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=9080 &

sleep 3s

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

curl -sSN https://ppng.io/${KEYWORD}req \
  | stdbuf -i0 -o0 openssl aes-256-ctr -d -pass "pass:none" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | socat - tcp4:127.0.0.1:3632 \
  | stdbuf -i0 -o0 openssl aes-256-ctr -pass "pass:none" -bufsize 1 -pbkdf2 -iter 1000 -md sha256 \
  | curl -m 300 -sSNT - https://ppng.io/${KEYWORD}res &

echo "${KEYWORD}" >/var/www/html/auth/keyword.txt

# curl -sSLO https://github.com/tshr20180821/render-10/raw/main/socat.sh
curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/socat2.sh?$(date +%s)
curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/socat3.sh?$(date +%s)
# curl -sSLO https://github.com/tshr20180821/render-10/raw/main/piping-tunnel.sh

chmod +x ./*.sh

# sleep 5s && TARGET_PORT=8022 ./socat.sh &

sleep 5s && TARGET_PORT=8022 ./socat2.sh &

sleep 10s && TARGET_PORT=23 ./socat3.sh &

# sleep 10s && TARGET_PORT=10022 ./piping-tunnel.sh &

sleep 15s && ss -anpt && ps aux &

# 72 : 12h
# for i in {1..72}; do \
#  for j in {1..10}; do sleep 60s && echo "${i} ${j}"; done \
#   && ss -anpt \
#   && ps aux \
#   && curl -sS -A "keep instance" -u "${BASIC_USER}":"${BASIC_PASSWORD}" https://"${RENDER_EXTERNAL_HOSTNAME}"/; \
# done &
for i in {1..2}; do \
  for j in {1..10}; do \
    sleep 60s \
     && echo "${i} ${j}" \
     && curl -sS ${PIPING_SERVER}/help >/dev/null 2>&1; \
  done \
   && ss -anpt \
   && ps aux \
   && curl -sS -A "keep instance" -u "${BASIC_USER}":"${BASIC_PASSWORD}" https://"${RENDER_EXTERNAL_HOSTNAME}"/?$(date +%s); \
done &
