#!/bin/bash
# Incremental Build Script for BaseOne Browser
# Company: BaseCode LLC
# Product: BaseOne
#
# This script performs an incremental build, rebuilding only changed files.
# Much faster than full build (10-30 minutes vs 2-4 hours).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="/Volumes/External/BaseChrome/ungoogled-chromium/build/src"
OUT_DIR="$SRC_DIR/out/Default"

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
echo "BaseOne Browser - Incremental Build"
echo "==========================================="
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    error "Source directory not found: $SRC_DIR"
    echo ""
    echo "You need to run a full build first."
    echo ""
    echo "If this is your first time:"
    echo "  ./scripts/init.sh     # Complete setup (clone + build, 2-4 hours)"
    echo ""
    echo "If source exists but not built yet:"
    echo "  cd ../ungoogled-chromium && export PYTHON=python3.13 && ./build.sh"
    echo ""
    exit 1
fi

# Check if out directory exists
if [ ! -d "$OUT_DIR" ]; then
    error "Build directory not found: $OUT_DIR"
    echo ""
    echo "You need to run a full build first."
    echo ""
    echo "Run the full build with:"
    echo "  cd ../ungoogled-chromium && export PYTHON=python3.13 && ./build.sh"
    echo ""
    exit 1
fi

# Check if args.gn exists
if [ ! -f "$OUT_DIR/args.gn" ]; then
    error "Build configuration not found: $OUT_DIR/args.gn"
    error "You need to run a full build first with ./scripts/init.sh"
fi

cd "$SRC_DIR"

# Get number of modified files
MODIFIED_COUNT=$(git status --short | wc -l | tr -d ' ')

if [ "$MODIFIED_COUNT" -eq 0 ]; then
    warn "No modified files detected. Build may be unnecessary."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Build cancelled"
        exit 0
    fi
else
    log "Found $MODIFIED_COUNT modified files"
    log "Modified files (first 10):"
    git status --short | head -10
    if [ "$MODIFIED_COUNT" -gt 10 ]; then
        log "... and $((MODIFIED_COUNT - 10)) more files"
    fi
    echo ""
fi

# Estimate build time based on modified files
if [ "$MODIFIED_COUNT" -lt 10 ]; then
    info "Estimated build time: 5-10 minutes"
elif [ "$MODIFIED_COUNT" -lt 50 ]; then
    info "Estimated build time: 10-20 minutes"
else
    info "Estimated build time: 20-30 minutes"
fi

echo ""
log "Starting incremental build..."
log "Build directory: $OUT_DIR"
log "Using $(nproc 2>/dev/null || sysctl -n hw.ncpu) CPU cores"
echo ""

# Start build with timestamp
START_TIME=$(date +%s)

log "Running: ninja -C out/Default chrome"
echo ""

# Run ninja build
if ninja -C out/Default chrome; then
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
    log "Built app: $OUT_DIR/BaseOne.app"

    # Show app size
    if [ -d "$OUT_DIR/BaseOne.app" ]; then
        APP_SIZE=$(du -sh "$OUT_DIR/BaseOne.app" | cut -f1)
        log "App size: $APP_SIZE"
    fi

    echo ""
    log "Backing up build artifacts..."
    "$SCRIPT_DIR/backup_build.sh"

    echo ""
    log "Next steps:"
    log "  1. Test the app: open '$OUT_DIR/BaseOne.app'"
    log "  2. If feature works: git commit"
    log "  3. Create DMG: ./scripts/package.sh"
    log "  4. Create release: ./scripts/release.sh -v 0.1.0 -c 'Codename'"
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
    log "Check build errors above"
    log "Common issues:"
    log "  - Syntax errors in modified files"
    log "  - Missing dependencies"
    log "  - Conflicting patches"
    echo ""
    log "To reset and try again:"
    log "  cd $SRC_DIR"
    log "  git reset --hard HEAD"
    log "  git clean -fd"
    log "  cd $BASE_DIR"
    log "  ./scripts/apply_base.sh"
    log "  ./scripts/build_incremental.sh"
    echo ""
    exit 1
fi
