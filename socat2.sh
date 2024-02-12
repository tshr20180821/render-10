#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

{ \
  echo "curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} https://${RENDER_EXTERNAL_HOSTNAME}/auth/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} >key.txt"; \
  echo "set +H"; \
  echo "socat -4 tcp4-listen:8022,bind=127.0.0.1 'exec:curl -NsS https\://ppng.io/${KEYWORD}res!!exec:curl -NsST - https\://ppng.io/${KEYWORD}req' &"; \
  echo "set -H"; \
  echo "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${SSH_USER} -p 8022 127.0.0.1 -i ./key.txt"; \
} >MESSAGE.txt

cat MESSAGE.txt

{ \
  echo "#!/bin/bash"; \
  echo "";
  echo "set -x";
  echo "cat - | openssl aes-256-cbc -pass ${PASSWORD} -base64 | curl -NsS https://ppng.io/${KEYWORD}req"; \
} >./req.sh

chmod +x ./req.sh

{ \
  echo "#!/bin/bash"; \
  echo "";
  echo "set -x";
  echo "curl -m 3600 -NsST - https://ppng.io/${KEYWORD}res | openssl aes-256-cbc -d -pass ${PASSWORD} -base64"; \
} >./res.sh

chmod +x ./res.sh

# socat -4 "exec:curl -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:${TARGET_PORT}
socat -4 "exec:/usr/src/app/req.sh!!exec:/usr/src/app/res.sh" \
  tcp4:127.0.0.1:${TARGET_PORT}
