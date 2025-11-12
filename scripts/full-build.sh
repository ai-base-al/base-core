#!/bin/bash
# Full Build Script for Base Browser
# Company: BaseCode LLC
# Product: Base Dev
#
# This script performs a full build of the browser.
# Run this after init.sh completes.
# Build time: 2-4 hours
#
# One script, one job: This ONLY builds (ninja). It does NOT initialize.
# Run init.sh first to initialize the environment.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
UNGOOGLED_DIR="$(dirname "$BASE_DIR")/ungoogled-chromium-macos"
SRC_DIR="$UNGOOGLED_DIR/build/src"
OUT_DIR="$SRC_DIR/out/Default"
LOG_FILE="$BASE_DIR/logs/build.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')] INFO:${NC} $1"
}

echo "==========================================="
echo "Base Browser - Full Build"
echo "==========================================="
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    error "Source directory not found: $SRC_DIR"
    echo ""
    echo "Run initialization first:"
    echo "  ./scripts/init.sh"
    exit 1
fi

# Check if out directory exists
if [ ! -d "$OUT_DIR" ]; then
    error "Build directory not found: $OUT_DIR"
    echo ""
    echo "Run initialization first:"
    echo "  ./scripts/init.sh"
    exit 1
fi

# Check if args.gn exists (means GN was run)
if [ ! -f "$OUT_DIR/args.gn" ]; then
    error "Build not configured: $OUT_DIR/args.gn not found"
    echo ""
    echo "Run initialization first:"
    echo "  ./scripts/init.sh"
    exit 1
fi

mkdir -p "$BASE_DIR/logs"

log "Starting full build (this will take 2-4 hours)..."
log "Build log: $LOG_FILE"
log "Source: $SRC_DIR"
log "Output: $OUT_DIR"
echo ""

# Start build with timestamp
START_TIME=$(date +%s)

cd "$SRC_DIR"

log "Running: ninja -C out/Default chrome chromedriver"
echo ""

# Run ninja build
if ninja -C out/Default chrome chromedriver 2>&1 | tee "$LOG_FILE"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    MINUTES=$((DURATION / 60))
    SECONDS=$((DURATION % 60))

    echo ""
    echo "==========================================="
    log "Build completed successfully!"
    echo "==========================================="
    echo ""
    log "Build time: ${MINUTES}m ${SECONDS}s"

    # Check if browser was built
    if [ -d "$OUT_DIR/Chromium.app" ]; then
        APP_SIZE=$(du -sh "$OUT_DIR/Chromium.app" | cut -f1)
        log "Built app: $OUT_DIR/Chromium.app"
        log "App size: $APP_SIZE"
    fi

    echo ""
    log "Next steps:"
    log "  1. Apply Base Dev branding: ./scripts/apply_base.sh"
    log "  2. Test the browser: open '$OUT_DIR/Chromium.app'"
    log "  3. For daily development: ./scripts/build_incremental.sh"
    echo ""

else
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    MINUTES=$((DURATION / 60))
    SECONDS=$((DURATION % 60))

    echo ""
    echo "==========================================="
    error "Build failed after ${MINUTES}m ${SECONDS}s"
    echo "==========================================="
    echo ""
    log "Check build log: $LOG_FILE"
    echo ""
    exit 1
fi
