#!/bin/bash

# Switch to the container's working directory
cd /home/container

# FORCE FIX: Jika startup command bawaan panel salah (masih Node.js)
if [[ "${STARTUP}" == *"npm"* ]] || [[ "${STARTUP}" == *"node"* ]]; then
    STARTUP="if [ ! -z \"\${PRE_STARTUP_COMMAND}\" ]; then eval \${PRE_STARTUP_COMMAND}; fi; if [ -d .git ] && [ \"\${AUTO_UPDATE}\" = \"1\" ]; then git pull; fi; if [ -f requirements.txt ]; then pip install -q -r requirements.txt; fi; exec python \${PY_FILE}"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Run the Server
eval ${MODIFIED_STARTUP}
