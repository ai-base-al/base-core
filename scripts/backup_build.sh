#!/bin/bash
# Backup Build Artifacts - Auto-run after successful builds
# Backs up entire out/Default/ to enable incremental builds after restore

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="/Volumes/External/BaseChrome/ungoogled-chromium/build/src"
OUT_DIR="$SRC_DIR/out/Default"
BACKUP_DIR="$BASE_DIR/backups/latest"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')] INFO:${NC} $1"
}

echo "==========================================="
echo "BaseOne Build Backup"
echo "==========================================="
echo ""

# Check if out/Default exists
if [ ! -d "$OUT_DIR" ]; then
    echo "Error: Build directory not found: $OUT_DIR"
    echo "Nothing to backup"
    exit 1
fi

# Check if BaseOne.app exists
if [ ! -d "$OUT_DIR/BaseOne.app" ]; then
    echo "Error: BaseOne.app not found in $OUT_DIR"
    echo "Build may have failed"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Get version info
VERSION=$(cat "$BASE_DIR/VERSION" 2>/dev/null || echo "unknown")
GIT_COMMIT=$(cd "$BASE_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
APP_SIZE=$(du -sh "$OUT_DIR/BaseOne.app" | cut -f1)

# Get applied patches
PATCHES=()
if [ -f "$BASE_DIR/patches/series" ]; then
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        PATCHES+=("$line")
    done < "$BASE_DIR/patches/series"
fi

log "Backing up build artifacts..."
info "Source: $OUT_DIR"
info "Destination: $BACKUP_DIR"
info "Version: $VERSION"
info "Git commit: $GIT_COMMIT"
echo ""

# Remove old backup if exists
if [ -f "$BACKUP_DIR/out_Default.tar.gz" ]; then
    OLD_SIZE=$(du -sh "$BACKUP_DIR/out_Default.tar.gz" | cut -f1)
    info "Removing previous backup ($OLD_SIZE)..."
    rm -f "$BACKUP_DIR/out_Default.tar.gz"
fi

# Create tarball
log "Creating compressed archive..."
START_TIME=$(date +%s)

cd "$SRC_DIR"
tar -czf "$BACKUP_DIR/out_Default.tar.gz" out/Default/ 2>/dev/null

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
BACKUP_SIZE=$(du -sh "$BACKUP_DIR/out_Default.tar.gz" | cut -f1)

# Create metadata file
cat > "$BACKUP_DIR/backup_info.json" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "version": "$VERSION",
  "git_commit": "$GIT_COMMIT",
  "chromium_version": "142.0.7444.134",
  "app_size": "$APP_SIZE",
  "backup_size": "$BACKUP_SIZE",
  "backup_duration_seconds": $DURATION,
  "patches_applied": [
$(printf '    "%s"' "${PATCHES[@]}" | paste -sd ',' -)
  ]
}
EOF

echo ""
echo "==========================================="
log "Backup complete!"
echo "==========================================="
echo ""
log "Backup location: $BACKUP_DIR"
log "Archive size: $BACKUP_SIZE"
log "Compression time: ${DURATION}s"
log "App size: $APP_SIZE"
echo ""
info "This backup can be restored with: ./scripts/restore_build.sh"
echo ""
