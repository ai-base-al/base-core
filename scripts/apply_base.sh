#!/bin/bash
# Apply all Base Browser patches in correct order
# Company: BaseCode LLC
# Product: BaseOne

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="/Volumes/External/BaseChrome/ungoogled-chromium/build/src"
PATCHES_DIR="$BASE_DIR/patches"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

echo "==========================================="
echo "Applying Base Browser Patches"
echo "==========================================="
echo ""
log "Base directory: $BASE_DIR"
log "Source directory: $SRC_DIR"
log "Patches directory: $PATCHES_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    error "Source directory not found: $SRC_DIR"
fi

cd "$SRC_DIR"

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    warn "Not a git repository. Continuing anyway..."
fi

# Step 1: Apply custom patches from patches/series
log "Step 1: Applying custom patches from patches/series..."
echo ""

if [ ! -f "$PATCHES_DIR/series" ]; then
    warn "No patches/series file found, skipping custom patches"
else
    PATCH_COUNT=0
    while IFS= read -r patch_name || [ -n "$patch_name" ]; do
        # Skip empty lines and comments
        [[ -z "$patch_name" || "$patch_name" =~ ^#.*$ ]] && continue

        PATCH_FILE="$PATCHES_DIR/$patch_name"

        if [ ! -f "$PATCH_FILE" ]; then
            warn "Patch file not found: $PATCH_FILE, skipping"
            continue
        fi

        log "Applying patch: $patch_name"

        # Try to apply the patch
        if patch -p1 --dry-run < "$PATCH_FILE" > /dev/null 2>&1; then
            patch -p1 < "$PATCH_FILE"
            PATCH_COUNT=$((PATCH_COUNT + 1))
            log "  Successfully applied: $patch_name"
        else
            warn "  Patch already applied or conflicts: $patch_name"
        fi

        echo ""
    done < "$PATCHES_DIR/series"

    log "Applied $PATCH_COUNT custom patches"
fi

echo ""

# Step 2: Apply branding (strings + icons)
log "Step 2: Applying BaseOne branding..."
echo ""

if [ -f "$BASE_DIR/scripts/apply_baseone_branding.sh" ]; then
    "$BASE_DIR/scripts/apply_baseone_branding.sh"
else
    warn "Branding script not found, skipping"
fi

echo ""

# Summary
echo "==========================================="
log "All Base Browser Patches Applied"
echo "==========================================="
echo ""

log "Modified files:"
git status --short | head -20
TOTAL_MODIFIED=$(git status --short | wc -l | tr -d ' ')
if [ "$TOTAL_MODIFIED" -gt 20 ]; then
    log "... and $((TOTAL_MODIFIED - 20)) more files"
fi

echo ""
log "Next steps:"
log "  1. Review changes: cd $SRC_DIR && git diff"
log "  2. Build: cd $BASE_DIR && ./scripts/build.sh"
echo ""
