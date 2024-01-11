FROM httpd:2.4

EXPOSE 80

SHELL ["/bin/bash", "-c"]

WORKDIR /app

RUN set -x \
 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY --chmod=755 ./app/start_pre.sh ./

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/bin/bash","/app/start_pre.sh"]
