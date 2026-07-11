ARG GOLANG_VERSION=1.23
FROM        --platform=$TARGETOS/$TARGETARCH golang:${GOLANG_VERSION}-alpine

RUN         apk add --update --no-cache \
                ca-certificates \
                tzdata \
                git \
                bash \
                curl \
                build-base \
                procps \
                jemalloc \
                bind-tools \
                zip \
                unzip \
                tar \
                wget \
                openssl \
                jq \
            && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
# Using ENTRYPOINT with exec-form to ensure signals are passed to entrypoint.sh
ENTRYPOINT  ["/bin/bash", "/entrypoint.sh"]
