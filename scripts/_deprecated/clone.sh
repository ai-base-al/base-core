#!/bin/bash
# Base Dev - Clone Chromium Source
# Clones Chromium source code using ungoogled-chromium
# Run this only once, or when you need a fresh source tree

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
SRC_DIR="$BASE_CORE_DIR/src"
LOGS_DIR="$BASE_CORE_DIR/logs"
LOG_FILE="$LOGS_DIR/clone.log"

mkdir -p "$LOGS_DIR"

echo "Base Dev - Clone Chromium Source"
echo "Log file: $LOG_FILE"
echo "================================"
echo ""

# Check if ungoogled-chromium exists
if [ ! -d "$UNGOOGLED_DIR" ]; then
  echo "Error: ungoogled-chromium directory not found at $UNGOOGLED_DIR"
  exit 1
fi

# Check if source already exists
if [ -d "$UNGOOGLED_DIR/build/src/.git" ]; then
  echo "Source already exists at $UNGOOGLED_DIR/build/src"
  echo ""
  read -p "Do you want to delete and re-clone? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Keeping existing source"
    exit 0
  fi
  echo "Removing existing source..."
  rm -rf "$UNGOOGLED_DIR/build/src"
fi

echo "Step 1: Checking Python 3.13 installation"
if ! command -v python3.13 &> /dev/null; then
  echo "Python 3.13 not found. Installing via Homebrew..."
  if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Please install Homebrew first"
    exit 1
  fi
  brew install python@3.13
else
  echo "Python 3.13 found: $(python3.13 --version)"
fi
echo ""

echo "Step 2: Cloning Chromium source"
echo "This will download ~10 GB and may take 30-60 minutes"
echo ""
cd "$UNGOOGLED_DIR"
export PYTHON=python3.13
./build.sh 2>&1 | tee -a "$LOG_FILE"

if [ ! -d "$UNGOOGLED_DIR/build/src/.git" ]; then
  echo ""
  echo "ERROR: Clone failed - source directory not found"
  echo "Check logs/clone.log for details"
  exit 1
fi

echo ""
echo "Step 3: Creating symlink to source"
if [ -L "$SRC_DIR" ]; then
  echo "Symlink already exists at $SRC_DIR"
elif [ -e "$SRC_DIR" ]; then
  echo "Removing existing $SRC_DIR and creating symlink..."
  rm -rf "$SRC_DIR"
  ln -s "$UNGOOGLED_DIR/build/src" "$SRC_DIR"
else
  echo "Creating symlink: $SRC_DIR -> $UNGOOGLED_DIR/build/src"
  ln -s "$UNGOOGLED_DIR/build/src" "$SRC_DIR"
fi

echo ""
echo "=========================================="
echo "Clone complete!"
echo "=========================================="
echo ""
echo "Source location: $UNGOOGLED_DIR/build/src"
echo "Symlink: $SRC_DIR -> $UNGOOGLED_DIR/build/src"
echo ""
echo "Next steps:"
echo "  1. Run ./scripts/build.sh to build the browser"
echo "  2. Or run ./scripts/init.sh to build + apply patches"
