#!/bin/bash
sleep 1

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


# Replace placeholders in the startup command
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

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
