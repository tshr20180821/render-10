#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

cat /etc/apache2/sites-enabled/apache.conf

ls -lang /etc/apache2/sites-enabled/

# apt

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  aria2 \
  >/dev/null &

curl -sSLo /usr/local/sbin/apt-fast https://raw.githubusercontent.com/ilikenwf/apt-fast/master/apt-fast
chmod +x /usr/local/sbin/apt-fast

echo "MIRRORS=('http://deb.debian.org/debian','http://cdn-fastly.deb.debian.org/debian','http://ftp.debian.org/debian,http://mirror.coganng.com/debian/,http://mirror.sg.gs/debian/,http://ossmirror.mycloud.services/debian/,http://ftp.nara.wide.ad.jp/debian/,http://ftp.kddilabs.jp/pub/debian/,http://ftp.riken.jp/Linux/debian/debian/')" >/etc/apt-fast.conf

wait

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
# curl -sSLo /var/www/html/auth/distccd.php https://github.com/tshr20180821/render-10/raw/main/distccd.php &

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=$(($(nproc)/2)) --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=3600

# sshd

if [ ! -z "${PIPING_SERVER}" ]; then
  # MARK 02
  curl -sSI ${PIPING_SERVER} ${PIPING_SERVER_SPARE} &
fi

# MARK 03
DEBIAN_FRONTEND=noninteractive apt-fast install -y --no-install-recommends \
  dropbear \
  jq \
  netcat-openbsd \
  openssh-server &

# ROOT_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
export SSH_USER=$(tr -dc 'a-z' </dev/urandom | fold -w 1 | head -n 1)$(tr -dc 'a-z0-9' </dev/urandom | fold -w 15 | head -n 1)
export SSH_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# ls -lang /etc/ssh/sshd_config.d/

mkdir /var/run/sshd
# echo "root:${ROOT_PASSWORD}" | chpasswd
# echo "root:rootpassword" | chpasswd

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

# MARK 01 02 03
wait

ssh-keygen -f /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} -t rsa -N ""

sed -i 's/root/'${SSH_USER}'/' /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub
cat /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub >>/etc/dropbear/authorized_keys
cat /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub >>/home/${SSH_USER}/.ssh/authorized_keys

chown -R ${SSH_USER}:users /home/${SSH_USER}

echo "PS1=\"user@${RENDER_EXTERNAL_HOSTNAME//.onrender.com/}:\\w\\$ \"" >>/home/${SSH_USER}/.bashrc
# cat /home/${SSH_USER}/.bashrc

cp /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} /var/www/html/auth/
chmod 666 /var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}

dropbear --help
dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
ls -lang /etc/dropbear/
# /usr/sbin/dropbear -Eswp 127.0.0.1:8022 -p 127.0.0.1:9022 -p 127.0.0.1:10022
/usr/sbin/dropbear -Eswp 127.0.0.1:8022 -I 3600

# curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
# ./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

# curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
# ./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=9080 &

TEST_STRING="$(echo -n "${RENDER_EXTERNAL_HOSTNAME}""$(date +%Y/%m/%d)" | base64 -w 0)"
TEST_STRING="$(echo -n "${TEST_STRING}" | sed 's/[+\/=]//g')"
echo "${TEST_STRING}"

sleep 3s

# curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/build_memcached.sh?$(date +%s)
# curl -sSLO https://github.com/tshr20180821/render-10/raw/main/socat.sh
# curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/socat2.sh?$(date +%s)
# curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/socat3.sh?$(date +%s)
curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/socat4.sh?$(date +%s)
# curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/socat5.sh?$(date +%s)
# curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/ssh.sh?$(date +%s)
# curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/piping-tunnel.sh?$(date +%s)
curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-10/main/dotnet.sh?$(date +%s)

chmod +x ./*.sh

# ./build_memcached.sh &

# sleep 5s && TARGET_PORT=8022 ./socat.sh &

# sleep 5s && TARGET_PORT=8022 ./socat2.sh &

# sleep 10s && TARGET_PORT=23 ./socat3.sh &

# sleep 5s && TARGET_PORT=8022 ./socat4.sh &

# sleep 5s && TARGET_PORT=8022 ./socat5.sh &

# sleep 5s && TARGET_PORT=8022 ./ssh.sh &

# sleep 5s && TARGET_PORT=8022 ./piping-tunnel.sh &

# sleep 15s && ss -anpt && ps aux &

./dotnet.sh

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
     && ps aux \
     && curl -sSI ${PIPING_SERVER} ${PIPING_SERVER_SPARE} >/dev/null 2>&1; \
  done \
   && ss -anpt \
   && ps aux \
   && curl -sS -A "keep instance" -u "${BASIC_USER}":"${BASIC_PASSWORD}" https://"${RENDER_EXTERNAL_HOSTNAME}"/?$(date +%s); \
done &
