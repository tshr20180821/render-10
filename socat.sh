#!/bin/bash

set -x

while true
do
  echo start socat
  KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
  echo "KEYWORD : ${KEYWORD}"
  socat "exec:curl --http1.1 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req!!exec:curl --http1.1 -m 3600 -u ${BASIC_USER}\:${BASIC_PASSWORD} -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res" \
    tcp:127.0.0.1:${TARGET_PORT}
  echo finish socat
done
