#!/bin/bash
# Base Dev - Initial Setup Script
# This script sets up a complete build environment from scratch
# Run this only once or when setting up a new development machine

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
SRC_DIR="$BASE_CORE_DIR/src"

echo "Base Dev - Initial Setup"
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

echo "Step 1: Running ungoogled-chromium build script"
echo "This will:"
echo "  - Clone Chromium source (~10 GB)"
echo "  - Download build dependencies (~2 GB)"
echo "  - Apply ungoogled-chromium patches"
echo "  - Configure build system"
echo "  - Build Chromium (2-4 hours)"
echo ""

cd "$UNGOOGLED_DIR"
./build.sh

echo ""
echo "Step 2: Moving built source to base-core"
BUILD_SRC="$UNGOOGLED_DIR/build/src"
if [ -d "$BUILD_SRC" ]; then
  echo "Moving $BUILD_SRC to $SRC_DIR..."
  mv "$BUILD_SRC" "$SRC_DIR"
else
  echo "Error: Build source not found at $BUILD_SRC"
  echo "ungoogled-chromium build may have failed"
  exit 1
fi

echo ""
echo "Step 3: Applying Base Dev patches"
cd "$BASE_CORE_DIR"
./scripts/patch.sh

echo ""
echo "Step 4: Rebuilding with Base Dev patches"
./scripts/build.sh

echo ""
echo "=========================================="
echo "Initial setup complete!"
echo "=========================================="
echo ""
echo "Browser location: $SRC_DIR/out/Default/Base Dev.app"
echo ""
echo "To run the browser:"
echo "  open \"$SRC_DIR/out/Default/Base Dev.app\""
echo ""
echo "For daily development:"
echo "  - Make your changes to source files in src/"
echo "  - Run ./scripts/build.sh for incremental builds (10-30 min)"
echo ""
echo "To update ungoogled-chromium:"
echo "  - Run ./scripts/sync.sh (triggers full rebuild)"
