#!/bin/bash

set -x
set +H

socat -h

PIPING_SERVER=$(echo ${PIPING_SERVER} | sed 's/:/\\:/')
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "KEYWORD : ${KEYWORD}"

for i in {1..10}
do
  echo socat -d tcp4-listen:8022,bind=127.0.0.1,reuseaddr,fork \\ \
    \"exec:curl -NsS ${PIPING_SERVER}/${KEYWORD}res!!exec:curl -NsST - ${PIPING_SERVER}/${KEYWORD}req\"

  echo start socat 1.1 ${i}
  # socat "exec:curl --http1.1 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl --http1.1 -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  #   tcp:127.0.0.1:${TARGET_PORT}
  socat -ddd -x -4 "exec:curl -v -k --http1.1 -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -v -k --http1.1 -m 3600 -NsST - ${PIPING_SERVER}/${KEYWORD}res" \
    tcp4:127.0.0.1:${TARGET_PORT}

  echo start socat 2 ${i}
  # socat "exec:curl -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  #   tcp:127.0.0.1:${TARGET_PORT}
  socat -ddd -x -4 "exec:curl -v -k -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -v -k -m 3600 -NsST - ${PIPING_SERVER}/${KEYWORD}res" \
    tcp4:127.0.0.1:${TARGET_PORT}
done
