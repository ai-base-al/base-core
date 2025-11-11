#!/bin/bash
# Base Dev - Incremental Build Script
# This script performs fast incremental builds (10-30 minutes)
# Use this for daily development work

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$BASE_CORE_DIR/src"
OUT_DIR="$SRC_DIR/out/Default"
LOGS_DIR="$BASE_CORE_DIR/logs"
LOG_FILE="$LOGS_DIR/build.log"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

echo "Base Dev - Incremental Build"
echo "Log file: $LOG_FILE"
echo "=============================="
echo ""
echo "Source directory: $SRC_DIR"
echo "Output directory: $OUT_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory not found at $SRC_DIR"
  echo "Run ./scripts/init.sh first to set up the build environment"
  exit 1
fi

# Check if build directory exists
if [ ! -d "$OUT_DIR" ]; then
  echo "Error: Build directory not found at $OUT_DIR"
  echo "Run ./scripts/init.sh first to configure the build"
  exit 1
fi

# Navigate to source directory
cd "$SRC_DIR"

# Run incremental build
echo "Starting incremental build..."
echo "This will take 10-30 minutes depending on changes"
echo ""

ninja -C out/Default chrome 2>&1 | tee "$LOG_FILE"

echo ""
echo "Build completed successfully!"
echo "Log saved to: $LOG_FILE"
echo "Binary location: $OUT_DIR/Base Dev.app"
echo ""
echo "To run the browser:"
echo "  open \"$OUT_DIR/Base Dev.app\""
