#!/bin/bash

set -x

curl -sSL -H 'Cache-Control: no-cache' -o /app/start_distccd.sh https://raw.githubusercontent.com/tshr20180821/render-10/main/app/start_distccd.sh?$(date +%s)
cat -n /app/start_distccd.sh
chmod +x /app/start_distccd.sh
# sleep 10s && /app/start_distccd.sh &

mkdir /usr/local/apache2/htdocs/auth
chown www-data:www-data /usr/local/apache2/htdocs/auth -R
echo '<HTML />'>/usr/local/apache2/htdocs/index.html

htpasswd -c -b /usr/local/apache2/htdocs/.htpasswd "${BASIC_USER}" "${BASIC_PASSWORD}"
chmod 644 /usr/local/apache2/htdocs/.htpasswd

curl -sSL -H 'Cache-Control: no-cache' -o /app/apache2.conf https://raw.githubusercontent.com/tshr20180821/render-10/main/app/apache2.conf?$(date +%s)
cat -n /app/apache2.conf

curl -sSL -H 'Cache-Control: no-cache' -o /app/apache2_LoadModule.conf https://raw.githubusercontent.com/tshr20180821/render-10/main/app/apache2_LoadModule.conf?$(date +%s)
cat -n /app/apache2_LoadModule.conf

apachectl -f /app/apache2.conf -DFOREGROUND
