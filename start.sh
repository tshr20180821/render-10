#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

# apt

apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends dnsutils >/dev/null &

# apache setting

a2dissite -q 000-default.conf

mkdir -p /var/www/html/auth

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

curl -sSLo /etc/apache2/sites-enabled/apache.conf https://github.com/tshr20180821/render-10/raw/main/apache.conf
sed -i s/__RENDER_EXTERNAL_HOSTNAME__/"${RENDER_EXTERNAL_HOSTNAME}"/g /etc/apache2/sites-enabled/apache.conf

htpasswd -c -b /var/www/html/.htpasswd "${BASIC_USER}" "${BASIC_PASSWORD}"
chmod 644 /var/www/html/.htpasswd
. /etc/apache2/envvars >/dev/null 2>&1

curl -sSLO https://github.com/tshr20180821/render-10/raw/main/start_after.sh

chmod +x ./start_after.sh

wait

export HOME_IP_ADDRESS=$(nslookup ${HOME_FQDN} 8.8.8.8 | tail -n2 | grep -o '[0-9]\+.\+')
if [ -z "${HOME_IP_ADDRESS}" ]; then
  HOME_IP_ADDRESS=127.0.0.1
fi

sleep 5s && ./start_after.sh &

# apache start

exec /usr/sbin/apache2 -DFOREGROUND
