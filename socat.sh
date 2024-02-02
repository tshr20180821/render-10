#!/bin/bash

set -x

PIPING_SERVER=$(echo ${PIPING_SERVER} | sed 's/:/\\:/')
KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
echo "KEYWORD : ${KEYWORD}"

while true
do
  echo start socat 1.1
  # socat "exec:curl -v --http1.1 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl -v --http1.1 -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  #   tcp:127.0.0.1:${TARGET_PORT}
  socat "exec:curl -v --http1.1 -NsS ${PIPING_SERVER}/${KEYWORD}req!!exec:curl -v --http1.1 -m 3600 -NsS --data-binary @- ${PIPING_SERVER}/${KEYWORD}res" \
    tcp:127.0.0.1:${TARGET_PORT}
  echo finish socat 1.1
  echo start socat 2
  # socat "exec:curl -v -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl -v -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
  #   tcp:127.0.0.1:${TARGET_PORT}
  socat "exec:curl -v -NsS ${PIPING_SERVER}/piping/${KEYWORD}req!!exec:curl -v -m 3600 -NsS --data-binary @- ${PIPING_SERVER}/piping/${KEYWORD}res" \
    tcp:127.0.0.1:${TARGET_PORT}
  echo finish socat 2
done
