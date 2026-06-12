FROM        --platform=$TARGETOS/$TARGETARCH golang:1.23-alpine

RUN         apk add --update --no-cache ca-certificates tzdata git bash \
            && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
# Using ENTRYPOINT with exec-form to ensure signals are passed to entrypoint.sh
ENTRYPOINT  ["/bin/bash", "/entrypoint.sh"]
