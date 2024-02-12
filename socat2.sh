#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

{ \
  echo "#!/bin/bash"; \
  echo "";
  echo "cat - | curl -NsS https://ppng.io/${KEYWORD}req"; \
} >./req.sh

chmod +x ./req.sh

{ \
  echo "#!/bin/bash"; \
  echo "";
  echo "cat - | curl -m 3600 -NsST - https://ppng.io/${KEYWORD}res"; \
} >./res.sh

chmod +x ./res.sh

# socat -4 "exec:curl -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:${TARGET_PORT}
socat -4 "exec:/usr/src/app/req.sh!!/usr/src/app/res.sh \
  tcp4:127.0.0.1:${TARGET_PORT}
