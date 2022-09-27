FROM debian:buster-slim

ARG BUILD_ENV=local

RUN if [ "${BUILD_ENV}" = "local" ]; then sed -i s/deb.debian.org/mirrors.aliyun.com/ /etc/apt/sources.list; fi &&\
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        libgtk2.0-0 libx11-xcb1 libxtst6 libnss3 libasound2 libdbus-glib-1-2 iptables xclip\
        dante-server tigervnc-standalone-server tigervnc-common dante-server psmisc flwm x11-utils\
        busybox libssl-dev iproute2 tinyproxy-bin

COPY ./MotionPro /opt/MotionPro

COPY ./docker-root /

COPY --from=fake-hwaddr fake-hwaddr/fake-hwaddr.so /usr/local/lib/fake-hwaddr.so

CMD ["start.sh"]
