#!/bin/bash
# Auto-patch depot_tools after ungoogled-chromium clones it
# This script wraps ungoogled-chromium/build.sh and automatically patches depot_tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
DEPOT_TOOLS_PATH="$UNGOOGLED_DIR/build/src/uc_staging/depot_tools"
PATCH_SCRIPT="$SCRIPT_DIR/patch_depot_tools.py"

echo "Auto-Patch Build Wrapper"
echo "========================"
echo ""
echo "This will:"
echo "  1. Run ungoogled-chromium build.sh"
echo "  2. Auto-patch depot_tools when detected"
echo ""

# Start ungoogled-chromium build in background
cd "$UNGOOGLED_DIR"
./build.sh > "$BASE_CORE_DIR/build-output.log" 2>&1 &
BUILD_PID=$!

echo "Build started (PID: $BUILD_PID)"
echo "Monitoring for depot_tools..."
echo ""

# Monitor for depot_tools creation
PATCHED=false
while kill -0 $BUILD_PID 2>/dev/null; do
    if [ -d "$DEPOT_TOOLS_PATH" ] && [ ! -f "$DEPOT_TOOLS_PATH/.patched" ] && [ "$PATCHED" = "false" ]; then
        echo "depot_tools detected! Applying patch..."
        python3 "$PATCH_SCRIPT" "$DEPOT_TOOLS_PATH"
        touch "$DEPOT_TOOLS_PATH/.patched"
        PATCHED=true
        echo "Patch applied successfully"
        echo ""
    fi
    sleep 2
done

# Wait for build to complete
wait $BUILD_PID
BUILD_EXIT=$?

echo ""
if [ $BUILD_EXIT -eq 0 ]; then
    echo "Build completed successfully!"
else
    echo "Build failed with exit code: $BUILD_EXIT"
    echo "Check $BASE_CORE_DIR/build-output.log for details"
fi

exit $BUILD_EXIT
