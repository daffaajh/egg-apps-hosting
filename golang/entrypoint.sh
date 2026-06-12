#!/bin/bash
cd /home/container

# Internal environment variable for the startup command
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# --- Performance Optimizations ---
if [ ! -z "${SERVER_MEMORY}" ]; then
    export GOMEMLIMIT=$((SERVER_MEMORY * 90 / 100))MiB
fi
if [ ! -z "${SERVER_CPU}" ] && [ "${SERVER_CPU}" != "0" ]; then
    export GOMAXPROCS=$(( (SERVER_CPU + 99) / 100 ))
fi
export GOGC=100

echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
# We remove 'exec' from here because the startup command might contain logic (if/then).
# Instead, the 'exec' should be inside the startup command itself, before the final application call.
eval "${MODIFIED_STARTUP}"
