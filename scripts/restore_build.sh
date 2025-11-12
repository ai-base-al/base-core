#!/bin/bash
# Restore Build Artifacts - Restore from backup to enable incremental builds

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="/Volumes/External/BaseChrome/ungoogled-chromium/build/src"
OUT_DIR="$SRC_DIR/out/Default"
BACKUP_DIR="$BASE_DIR/backups/latest"

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
echo "BaseOne Build Restore"
echo "==========================================="
echo ""

# Check if backup exists
if [ ! -f "$BACKUP_DIR/out_Default.tar.gz" ]; then
    error "No backup found at: $BACKUP_DIR/out_Default.tar.gz"
fi

if [ ! -f "$BACKUP_DIR/backup_info.json" ]; then
    warn "Backup metadata not found"
else
    # Display backup info
    log "Backup information:"
    echo ""
    if command -v jq &> /dev/null; then
        jq -r '
            "  Timestamp:        \(.timestamp)",
            "  Version:          \(.version)",
            "  Git commit:       \(.git_commit)",
            "  Chromium:         \(.chromium_version)",
            "  App size:         \(.app_size)",
            "  Backup size:      \(.backup_size)",
            "  Patches applied:  \(.patches_applied | length) patches"
        ' "$BACKUP_DIR/backup_info.json"
    else
        cat "$BACKUP_DIR/backup_info.json"
    fi
    echo ""
fi

# Check if out/Default already exists
if [ -d "$OUT_DIR" ]; then
    warn "Build directory already exists: $OUT_DIR"
    echo ""
    read -p "Do you want to remove it and restore from backup? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Restore cancelled"
        exit 0
    fi

    log "Removing existing build directory..."
    rm -rf "$OUT_DIR"
fi

# Create source directory if needed
mkdir -p "$SRC_DIR"

log "Restoring build artifacts..."
info "Source: $BACKUP_DIR/out_Default.tar.gz"
info "Destination: $SRC_DIR"
echo ""

# Extract tarball
START_TIME=$(date +%s)

cd "$SRC_DIR"
tar -xzf "$BACKUP_DIR/out_Default.tar.gz" 2>/dev/null

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Verify restoration
if [ ! -d "$OUT_DIR/BaseOne.app" ]; then
    error "Restore failed: BaseOne.app not found after extraction"
fi

APP_SIZE=$(du -sh "$OUT_DIR/BaseOne.app" | cut -f1)
OUT_SIZE=$(du -sh "$OUT_DIR" | cut -f1)

echo ""
echo "==========================================="
log "Restore complete!"
echo "==========================================="
echo ""
log "Restored to: $OUT_DIR"
log "App size: $APP_SIZE"
log "Total size: $OUT_SIZE"
log "Extraction time: ${DURATION}s"
echo ""
info "You can now run incremental builds with: ./scripts/build_incremental.sh"
echo ""
