#!/bin/bash

set -x

socat -h

PIPING_SERVER=$(echo ${PIPING_SERVER} | sed 's/:/\\:/')
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "KEYWORD : ${KEYWORD}"

# socat -ddd -v -4 "exec:curl -v -k -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -v -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:${TARGET_PORT}
# socat -4 "exec:curl -k -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:${TARGET_PORT}
# socat -ddd -v -4 "exec:curl -v -k -NsS https\://ppng.io/${KEYWORD}req!!exec:curl -v -k -m 3600 -NsST - https\://ppng.io/${KEYWORD}res" \
#   tcp4:127.0.0.1:8023

for i in {1..2}
do
  # echo socat -d tcp4-listen:8022,bind=127.0.0.1,reuseaddr,fork \\ \
  #   \"exec:curl -NsS ${PIPING_SERVER}/${KEYWORD}res!!exec:curl -NsST - ${PIPING_SERVER}/${KEYWORD}req\"

  echo start socat 1.1 ${i}
  # socat -ddd -v -4 "exec:curl -vk --http1.1 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl -vk --http1.1 -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  #   tcp:127.0.0.1:${TARGET_PORT}
  socat -4 "exec:curl --http1.1 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl --http1.1 -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
    tcp:127.0.0.1:${TARGET_PORT}

  curl -sSu ${BASIC_USER}:${BASIC_PASSWORD} -d 'dummy' https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req

  # socat -ddd -v -4 "exec:curl -v -k --http1.1 -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -v -k --http1.1 -m 3600 -NsST - ${PIPING_SERVER}/${KEYWORD}res" \
  #  tcp4:127.0.0.1:${TARGET_PORT}

  # echo start socat 2 ${i}
  # socat "exec:curl -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  #   tcp:127.0.0.1:${TARGET_PORT}
  # socat -ddd -v -4 "exec:curl -v -k -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -v -k -m 3600 -NsST - ${PIPING_SERVER}/${KEYWORD}res" \
  #   tcp4:127.0.0.1:${TARGET_PORT}
done
