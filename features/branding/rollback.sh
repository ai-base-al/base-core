#!/bin/bash
# Rollback Base Dev branding to original Chromium

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}${BOLD}════════════════════════════════════════${NC}"
echo -e "${YELLOW}${BOLD}   🔄 Rolling Back Branding${NC}"
echo -e "${YELLOW}${BOLD}════════════════════════════════════════${NC}"
echo ""

# Restore original files
FILES_TO_RESTORE=(
    "$SRC_DIR/chrome/app/theme/chromium/BRANDING"
    "$SRC_DIR/chrome/BUILD.gn"
    "$SRC_DIR/chrome/app/framework/Info.plist"
    "$SRC_DIR/chrome/app/app-Info.plist"
    "$SRC_DIR/chrome/app/chromium_strings.grd"
)

RESTORED=0
for FILE in "${FILES_TO_RESTORE[@]}"; do
    if [ -f "$FILE.orig" ]; then
        mv "$FILE.orig" "$FILE"
        echo -e "${GREEN}✓${NC} Restored: ${DIM}$(basename $FILE)${NC}"
        ((RESTORED++))
    fi
done

if [ $RESTORED -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No backup files found${NC}"
    echo -e "${DIM}Either branding was never applied, or files were already restored${NC}"
else
    echo ""
    echo -e "${GREEN}${BOLD}✨ Rollback Complete!${NC}"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo -e "  Rebuild: ${CYAN}./run/5_build_macos.sh -d${NC}"
    echo -e "  Result:  ${CYAN}Chromium.app${NC} (original branding)"
fi

echo ""