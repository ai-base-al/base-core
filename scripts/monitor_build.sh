#!/bin/bash
# Build Monitor - Checks build progress every 30 minutes
# Reports progress and notifies when complete

BUILD_PID=$1
LOG_FILE="/Volumes/External/BaseChrome/base-core/logs/build.log"
MONITOR_LOG="/Volumes/External/BaseChrome/base-core/logs/monitor.log"
CHECK_INTERVAL=1800  # 30 minutes in seconds

if [ -z "$BUILD_PID" ]; then
    echo "Usage: $0 <build_pid>"
    exit 1
fi

echo "Build Monitor Started" | tee -a "$MONITOR_LOG"
echo "Monitoring PID: $BUILD_PID" | tee -a "$MONITOR_LOG"
echo "Check interval: 30 minutes" | tee -a "$MONITOR_LOG"
echo "Started at: $(date)" | tee -a "$MONITOR_LOG"
echo "========================================" | tee -a "$MONITOR_LOG"

check_count=0

while kill -0 $BUILD_PID 2>/dev/null; do
    check_count=$((check_count + 1))
    current_time=$(date '+%H:%M:%S')

    # Extract current progress from build log
    if [ -f "$LOG_FILE" ]; then
        # Get last ninja progress line
        progress=$(tail -20 "$LOG_FILE" | grep -E '^\[[0-9]+/[0-9]+\]' | tail -1)

        if [ -n "$progress" ]; then
            # Extract numbers like [1234/54696]
            current=$(echo "$progress" | sed -E 's/.*\[([0-9]+)\/([0-9]+)\].*/\1/')
            total=$(echo "$progress" | sed -E 's/.*\[([0-9]+)\/([0-9]+)\].*/\2/')

            if [ -n "$current" ] && [ -n "$total" ]; then
                percentage=$(awk "BEGIN {printf \"%.1f\", ($current/$total)*100}")

                echo "" | tee -a "$MONITOR_LOG"
                echo "Check #$check_count at $current_time" | tee -a "$MONITOR_LOG"
                echo "Progress: $current / $total targets ($percentage%)" | tee -a "$MONITOR_LOG"

                # Extract what's currently being compiled
                current_task=$(echo "$progress" | sed -E 's/\[[0-9]+\/[0-9]+\] //')
                echo "Current: $current_task" | tee -a "$MONITOR_LOG"

                # Estimate time remaining (very rough)
                if [ $check_count -gt 1 ]; then
                    elapsed_mins=$((check_count * 30))
                    rate=$(awk "BEGIN {printf \"%.2f\", $current/$elapsed_mins}")
                    remaining=$(awk "BEGIN {printf \"%.0f\", ($total-$current)/$rate}")
                    hours=$((remaining / 60))
                    mins=$((remaining % 60))
                    echo "Estimated remaining: ${hours}h ${mins}m (rough estimate)" | tee -a "$MONITOR_LOG"
                fi
            fi
        else
            echo "Check #$check_count at $current_time - Build in progress (no ninja output yet)" | tee -a "$MONITOR_LOG"
        fi
    fi

    # Sleep for 30 minutes before next check
    sleep $CHECK_INTERVAL
done

echo "" | tee -a "$MONITOR_LOG"
echo "========================================" | tee -a "$MONITOR_LOG"
echo "BUILD COMPLETED!" | tee -a "$MONITOR_LOG"
echo "Finished at: $(date)" | tee -a "$MONITOR_LOG"
echo "Total checks: $check_count" | tee -a "$MONITOR_LOG"
echo "Total time: $((check_count * 30)) minutes" | tee -a "$MONITOR_LOG"
echo "========================================" | tee -a "$MONITOR_LOG"

# Notify completion (macOS notification)
osascript -e "display notification \"Chromium build completed successfully!\" with title \"Base Dev Build\" sound name \"Glass\""

# Create completion marker
echo "$(date)" > /Volumes/External/BaseChrome/base-core/.build_complete
