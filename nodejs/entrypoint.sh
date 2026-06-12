#!/bin/bash
sleep 1

# Make sure the container user has a home directory
cd /home/container

# Replace placeholders in the startup command
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
