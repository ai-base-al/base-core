#!/bin/bash
# Base Dev - Sync Script
# This script updates ungoogled-chromium and performs a full rebuild
# Run this when you want to update to a newer Chromium version

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
SRC_DIR="$BASE_CORE_DIR/src"
BACKUP_DIR="$BASE_CORE_DIR/backups"

echo "Base Dev - Sync ungoogled-chromium"
echo "==================================="
echo ""
echo "This will:"
echo "  1. Backup current build"
echo "  2. Update ungoogled-chromium"
echo "  3. Perform full rebuild (2-4 hours)"
echo "  4. Apply Base Dev patches"
echo ""
echo "ungoogled-chromium directory: $UNGOOGLED_DIR"
echo ""

# Check if ungoogled-chromium exists
if [ ! -d "$UNGOOGLED_DIR" ]; then
  echo "Error: ungoogled-chromium directory not found at $UNGOOGLED_DIR"
  exit 1
fi

# Create backup if source exists
if [ -d "$SRC_DIR" ]; then
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  BACKUP_NAME="Base-Dev-$TIMESTAMP"

  echo "Step 1: Creating backup"
  mkdir -p "$BACKUP_DIR"

  if [ -f "$SRC_DIR/out/Default/Base Dev.app" ]; then
    echo "Backing up Base Dev.app to $BACKUP_DIR/$BACKUP_NAME.app"
    cp -R "$SRC_DIR/out/Default/Base Dev.app" "$BACKUP_DIR/$BACKUP_NAME.app"
    echo "Backup created successfully"
  else
    echo "No built app found, skipping backup"
  fi

  echo ""
  read -p "Remove current source directory? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing $SRC_DIR..."
    rm -rf "$SRC_DIR"
  else
    echo "Keeping source directory"
    echo "Note: This may cause conflicts during rebuild"
  fi
else
  echo "No existing source directory found"
fi

echo ""
echo "Step 2: Updating ungoogled-chromium"
cd "$UNGOOGLED_DIR"

# Pull latest changes
git fetch origin
git pull origin master

# Clean any previous build artifacts
if [ -d "build" ]; then
  echo "Cleaning previous build artifacts..."
  rm -rf build
fi

echo ""
echo "Step 3: Building with updated ungoogled-chromium"
echo "This will take 2-4 hours..."
./build.sh

echo ""
echo "Step 4: Moving built source to base-core"
BUILD_SRC="$UNGOOGLED_DIR/build/src"
if [ -d "$BUILD_SRC" ]; then
  echo "Moving $BUILD_SRC to $SRC_DIR..."
  mv "$BUILD_SRC" "$SRC_DIR"
else
  echo "Error: Build source not found at $BUILD_SRC"
  exit 1
fi

echo ""
echo "Step 5: Applying Base Dev patches"
cd "$BASE_CORE_DIR"
./scripts/patch.sh

echo ""
echo "Step 6: Rebuilding with Base Dev patches"
./scripts/build.sh

echo ""
echo "=========================================="
echo "Sync complete!"
echo "=========================================="
echo ""
echo "Browser location: $SRC_DIR/out/Default/Base Dev.app"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "Previous build backed up to:"
  ls -t "$BACKUP_DIR" | head -1 | sed 's/^/  /'
  echo ""
fi
echo "To run the browser:"
echo "  open \"$SRC_DIR/out/Default/Base Dev.app\""
