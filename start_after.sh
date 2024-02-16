#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# apt

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  build-essential \
  curl \
  distcc \
  gcc-x86-64-linux-gnu \
  iproute2 \
  >/dev/null

# 72 : 12h
# for i in {1..72}; do \
#  for j in {1..10}; do sleep 60s && echo "${i} ${j}"; done \
#   && ss -anpt \
#   && ps aux \
#   && curl -sS -A "keep instance" -u "${BASIC_USER}":"${BASIC_PASSWORD}" https://"${RENDER_EXTERNAL_HOSTNAME}"/; \
# done &
for i in {1..72}; do \
  for j in {1..10}; do \
    sleep 60s \
     && echo "${i} ${j}" \
     && curl -sS ${PIPING_SERVER}/help >/dev/null 2>&1; \
  done \
   && ss -anpt \
   && ps aux; \
done &

# distccd

curl -sSL -o /var/www/html/auth/distccd.php https://github.com/tshr20180821/render-10/raw/main/distccd.php &

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

/usr/bin/distccd --port=3632 --listen=127.0.0.1 --user=nobody --jobs=$(($(nproc)/2)) --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180

# sshd

if [ ! -z "${PIPING_SERVER}" ]; then
  curl -sS ${PIPING_SERVER}/help
fi

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  dropbear \
  less \
  openssh-server \
  socat \
  vim \
  >/dev/null

ROOT_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
export SSH_USER=$(tr -dc 'a-z' </dev/urandom | fold -w 8 | head -n 1)
SSH_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# ls -lang /etc/ssh/sshd_config.d/

mkdir /var/run/sshd
echo "root:${ROOT_PASSWORD}" | chpasswd

export NOTVISIBLE='in users profile'
echo 'export VISIBLE=now' >> /etc/profile
cp /etc/profile /var/www/html/auth/profile.txt

# useradd -b /home -m -s /bin/bash ${SSH_USER}
useradd -b /home -m -N -s /bin/bash ${SSH_USER}
echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
usermod -aG users ${SSH_USER}
# usermod -aG sudo ${SSH_USER}

mkdir -p /home/${SSH_USER}/.ssh
chmod 700 /home/${SSH_USER}/.ssh

ssh-keygen -f /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} -t rsa -N ""

ls -lang /home/${SSH_USER}/.ssh/

sed -i 's/root/'${SSH_USER}'/' /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub
cat /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub >>/etc/dropbear/authorized_keys
cat /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}.pub >>/home/${SSH_USER}/.ssh/authorized_keys

chown -R ${SSH_USER}:users /home/${SSH_USER}

cp /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} /var/www/html/auth/
chmod 666 /var/www/html/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER}

dropbear --help
ls -lang /etc/dropbear/
/usr/sbin/dropbear -Eswp 127.0.0.1:8022 -p 127.0.0.1:9022

# curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
# ./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

sleep 3s

curl -sSL -O https://github.com/tshr20180821/render-10/raw/main/socat.sh
# curl -sSL -O https://github.com/tshr20180821/render-10/raw/main/socat2.sh
# curl -sSL -O https://github.com/tshr20180821/render-10/raw/main/socat3.sh
# curl -sSL -O https://github.com/tshr20180821/render-10/raw/main/piping-tunnel.sh
# curl -sSL -O https://github.com/tshr20180821/render-10/raw/main/piping-duplex.sh
curl -sSL -O https://github.com/tshr20180821/render-10/raw/main/fah.sh

chmod +x ./*.sh

./fah.sh &

sleep 5s && TARGET_PORT=9022 ./socat.sh &

# sleep 10s && TARGET_PORT=8022 ./socat2.sh &

# sleep 10s && TARGET_PORT=9022 ./piping-tunnel.sh &

# sleep 5s && TARGET_PORT=10022 ./piping-duplex.sh &

sleep 10s && ss -anpt && ps aux &
