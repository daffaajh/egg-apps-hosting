ARG         NODE_VERSION=25
FROM        --platform=$TARGETOS/$TARGETARCH node:${NODE_VERSION}-alpine

LABEL       author="dapaupau@sigaul.com" maintainer="dapaupau@sigaul.com"

# Install system dependencies, network debug tools, and jemalloc
RUN         apk add --update --no-cache \
                ca-certificates \
                tzdata \
                git \
                bash \
                curl \
                build-base \
                python3 \
                procps \
                jemalloc \
                bind-tools \
            && adduser -D -h /home/container container

# Pre-install global package managers and process manager
RUN         npm config set fetch-retries 5 \
            && npm config set fetch-retry-mintimeout 20000 \
            && npm config set fetch-retry-maxtimeout 120000 \
            && npm install -g pnpm pm2 --loglevel=error

# Set environment variables for container and pre-load jemalloc
ENV         USER=container \
            HOME=/home/container \
            UV_THREADPOOL_SIZE=16 \
            LD_PRELOAD=/usr/lib/libjemalloc.so.2

USER        container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
ENTRYPOINT  ["/bin/bash", "/entrypoint.sh"]
