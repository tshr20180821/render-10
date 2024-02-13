#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.deb
dpkg -i piping-duplex-0.3.0-release-trigger2-linux-amd64.deb

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

piping-duplex --help

script --help

# tty=$(readlink /proc/$$/fd/2)

# socat -ddd -v "exec:piping-duplex -c -s https\://ppng.io ${KEYWORD}res ${KEYWORD}req" tcp4:127.0.0.1:${TARGET_PORT}

{ \
  echo "#!/bin/bash"; \
  echo ""; \
  echo "set -x"; \
  echo "piping-duplex -c -s https://ppng.io ${KEYWORD}res ${KEYWORD}req"; \
} >./piping_duplex.sh

cat ./piping_duplex.sh

chmod +x ./piping_duplex.sh

for i in {1..2}
do
  socat -ddd -v 'exec:script -fc /usr/src/app/piping_duplex.sh' tcp4:127.0.0.1:${TARGET_PORT}
done
