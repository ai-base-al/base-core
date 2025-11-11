#!/bin/bash
# Base Dev - Initial Setup Script
# This script sets up a complete build environment from scratch
# Run this only once or when setting up a new development machine

set -e
set -o pipefail  # Make pipeline errors propagate correctly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
SRC_DIR="$BASE_CORE_DIR/src"
LOGS_DIR="$BASE_CORE_DIR/logs"
LOG_FILE="$LOGS_DIR/build.log"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

echo "Base Dev - Initial Setup"
echo "Log file: $LOG_FILE"
echo "========================"
echo ""
echo "This will set up a complete build environment"
echo "Expected time: 2-4 hours (includes full Chromium build)"
echo ""
echo "Base Core directory: $BASE_CORE_DIR"
echo "ungoogled-chromium directory: $UNGOOGLED_DIR"
echo "Source directory: $SRC_DIR"
echo ""

# Check if ungoogled-chromium exists
if [ ! -d "$UNGOOGLED_DIR" ]; then
  echo "Error: ungoogled-chromium directory not found at $UNGOOGLED_DIR"
  echo ""
  echo "Please clone ungoogled-chromium-macos first:"
  echo "  cd $(dirname "$BASE_CORE_DIR")"
  echo "  git clone https://github.com/ungoogled-software/ungoogled-chromium-macos.git ungoogled-chromium"
  exit 1
fi

# Check if source directory already exists
if [ -d "$SRC_DIR" ]; then
  echo "Warning: Source directory already exists at $SRC_DIR"
  read -p "Do you want to remove it and start fresh? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing existing source directory..."
    rm -rf "$SRC_DIR"
  else
    echo "Keeping existing source directory"
    echo "If you want to rebuild, use ./scripts/build.sh instead"
    exit 0
  fi
fi

echo "Step 1: Checking/cloning Chromium source"
if [ ! -d "$UNGOOGLED_DIR/build/src/.git" ]; then
  echo "Source not found, running clone script..."
  "$SCRIPT_DIR/clone.sh" 2>&1 | tee -a "$LOG_FILE"
  if [ $? -ne 0 ]; then
    echo "ERROR: Clone failed"
    exit 1
  fi
else
  echo "Source already exists at $UNGOOGLED_DIR/build/src"

  # Ensure symlink exists
  if [ ! -L "$SRC_DIR" ]; then
    echo "Creating symlink: $SRC_DIR -> $UNGOOGLED_DIR/build/src"
    ln -s "$UNGOOGLED_DIR/build/src" "$SRC_DIR"
  fi
fi
echo ""

echo "Step 2: Building ungoogled-chromium"
echo "Using -d flag to skip re-clone (just fetch updates)"
echo "This will take 2-4 hours..."
echo ""

cd "$UNGOOGLED_DIR"
export PYTHON=python3.13
./build.sh -d 2>&1 | tee -a "$LOG_FILE"
BUILD_EXIT=$?

if [ $BUILD_EXIT -ne 0 ]; then
  echo ""
  echo "ERROR: ungoogled-chromium build failed with exit code $BUILD_EXIT"
  echo "Check logs/build.log for details"
  exit 1
fi

BUILD_SRC="$UNGOOGLED_DIR/build/src"
echo "Build completed at: $BUILD_SRC"

echo ""
echo "Step 3: Applying Base Dev patches"
cd "$BASE_CORE_DIR"
./scripts/patch.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Patch application failed"
  exit 1
fi

echo ""
echo "Step 4: Rebuilding with Base Dev patches"
./scripts/build.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Build failed"
  exit 1
fi

echo ""
echo "=========================================="
echo "Initial setup complete!"
echo "=========================================="
echo ""
echo "Source location: $BUILD_SRC"
echo "Symlink: $SRC_DIR -> $BUILD_SRC"
echo "Browser location: $BUILD_SRC/out/Default/Base Dev.app"
echo ""
echo "To run the browser:"
echo "  open \"$BUILD_SRC/out/Default/Base Dev.app\""
echo ""
echo "For daily development:"
echo "  - Make your changes to source files in $BUILD_SRC"
echo "  - Run ./scripts/build.sh for incremental builds (10-30 min)"
echo ""
echo "To update ungoogled-chromium:"
echo "  - Run ./scripts/sync.sh (will fetch updates, not re-clone)"
echo ""
echo "Note: Source code stays in ungoogled-chromium/build/src permanently"
echo "      This prevents re-cloning on future builds!"
