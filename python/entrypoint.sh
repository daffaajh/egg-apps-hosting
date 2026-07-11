#!/bin/bash

cd /home/container

# --- System Performance Tuning (Swap/Cache) ---
if [ -w /proc/sys/vm/swappiness ] 2>/dev/null; then
    echo 10 > /proc/sys/vm/swappiness
fi

if [ -w /proc/sys/vm/vfs_cache_pressure ] 2>/dev/null; then
    echo 50 > /proc/sys/vm/vfs_cache_pressure
fi

if [ -w /sys/kernel/mm/transparent_hugepage/defrag ] 2>/dev/null; then
    echo "defer+madvise" > /sys/kernel/mm/transparent_hugepage/defrag
fi


# Detect and enable jemalloc for better memory management
if [ -f /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 ]; then
    export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
elif [ -f /usr/lib/aarch64-linux-gnu/libjemalloc.so.2 ]; then
    export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2
fi

# FORCE FIX: Jika startup command bawaan panel salah (masih Node.js)
if [[ "${STARTUP}" == *"npm"* ]] || [[ "${STARTUP}" == *"node"* ]]; then
    STARTUP="print_status() { echo -e \"\\n\\e[1;36m[YuraCloud]\\e[0m \\e[33m\$1...\\e[0m\"; }; if [ ! -z \"\${PRE_STARTUP_COMMAND}\" ]; then print_status \"Menjalankan pre-startup command\"; eval \${PRE_STARTUP_COMMAND}; fi; if [ -d .git ] && [ \"\${AUTO_UPDATE}\" = \"1\" ]; then print_status \"Menarik pembaruan kode dari GitHub\"; git pull; fi; if [ -f requirements.txt ]; then print_status \"Menginstal dependensi Python\"; pip install --user -q -r requirements.txt; fi; print_status \"Menjalankan aplikasi\"; exec python \${PY_FILE}"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Run the Server in background
eval ${MODIFIED_STARTUP} &
MAIN_PID=$!

# CPU Monitor Loop for Anti-DDoS / Optimization
(
  HIGH_CPU_COUNT=0
  while true; do
    sleep 5
    if ! kill -0 $MAIN_PID 2>/dev/null; then
       break
    fi
    CPU_USAGE=$(ps -p $MAIN_PID -o %cpu= | awk '{print int($1)}')
    if [ -z "$CPU_USAGE" ]; then continue; fi

    if [ "$CPU_USAGE" -ge 95 ]; then
      HIGH_CPU_COUNT=$((HIGH_CPU_COUNT + 1))
    else
      HIGH_CPU_COUNT=0
    fi

    # 1 minute continuous at 5 sec intervals = 12 times
    if [ "$HIGH_CPU_COUNT" -ge 12 ]; then
      echo "[ANTI-DDOS/OPTIMIZATION] CRITICAL: CPU at 100% continuously for 1 minute! Suspicious activity detected." >&2
      echo "[$(date)] Suspicious activity: CPU at 100% for 60s. Shutting down server." >> /home/container/suspicious_activity.log
      kill -9 $MAIN_PID
      exit 1
    fi
  done
) &

wait $MAIN_PID
