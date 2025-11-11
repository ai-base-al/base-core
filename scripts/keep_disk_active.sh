#!/bin/bash
# Keep external disk active during build
# This script periodically writes to the disk to prevent it from disconnecting

BUILD_PID=$1
DISK_PATH="/Volumes/External/BaseChrome/base-core/.disk_keepalive"

if [ -z "$BUILD_PID" ]; then
    echo "Usage: $0 <build_pid>"
    exit 1
fi

echo "Keeping disk active for build PID: $BUILD_PID"
echo "Keepalive file: $DISK_PATH"

# Touch the disk every 30 seconds while build is running
while kill -0 $BUILD_PID 2>/dev/null; do
    date > "$DISK_PATH"
    sleep 30
done

echo "Build process finished. Stopping disk keepalive."
rm -f "$DISK_PATH"
