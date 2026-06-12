ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim

LABEL author="YuraCloud" maintainer="dapaupau@sigaul.com"

# Optimize Python performance
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        curl \
        git \
        ca-certificates \
        iproute2 \
        tzdata \
        python3-dev \
        build-essential \
        libffi-dev \
        libssl-dev \
        libjemalloc2 \
    && useradd -m -d /home/container container \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Use jemalloc for better memory management (commented out for stability)
# ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

USER container
ENV USER=container HOME=/home/container PATH="${PATH}:/home/container/.local/bin"
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
