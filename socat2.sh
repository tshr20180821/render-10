#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

{ \
  echo "#!/bin/bash"; \
  echo "";
  echo "cat - | curl -NsS https://ppng.io/${KEYWORD}req"; \
} >./tmp001.sh

chmod +x ./tmp001.sh
cat ./tmp001.sh
pwd

# socat -ddd -v -4 "exec:curl -v -k -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -v -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:${TARGET_PORT}
socat -4 "exec:./tmp001.sh!!exec:curl -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
  tcp4:127.0.0.1:${TARGET_PORT}
