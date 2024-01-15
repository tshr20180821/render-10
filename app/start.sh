#!/bin/bash

set -x

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-10/raw/main/app/start_sshd.sh
cat -n ./start_sshd.sh
chmod +x ./start_sshd.sh
sleep 10s && ./start_sshd.sh &

for i in {1..10}; do sleep 60s && echo "${i}"; done \
 && ss -anpt \
 && ps aux \
 && curl -sS -u "${BASIC_USER}":"${BASIC_PASSWORD}" https://"${RENDER_EXTERNAL_HOSTNAME}"/; \
done &

mkdir /usr/local/apache2/htdocs/auth
chown www-data:www-data /usr/local/apache2/htdocs/auth -R
echo '<HTML />'>/usr/local/apache2/htdocs/index.html

htpasswd -c -b /usr/local/apache2/htdocs/.htpasswd "${BASIC_USER}" "${BASIC_PASSWORD}"
chmod 644 /usr/local/apache2/htdocs/.htpasswd

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-10/raw/main/app/apache2.conf
cat -n ./apache2.conf

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-10/raw/main/app/apache2_LoadModule.conf
cat -n ./apache2_LoadModule.conf

sed -i s/__RENDER_EXTERNAL_HOSTNAME__/"${RENDER_EXTERNAL_HOSTNAME}"/g ./apache2.conf

apachectl -f /app/apache2.conf -DFOREGROUND
