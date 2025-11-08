#!/usr/bin/env bash
# Base Chrome - Main Build Script
# Wraps ungoogled-chromium/build.sh with our patches

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}Base Chrome - Build System${NC}"
echo ""

# Apply depot_tools Python 3.14 fix if needed
if [ -d "$ROOT_DIR/ungoogled-chromium/build/src/uc_staging/depot_tools" ]; then
    if [ ! -f "$ROOT_DIR/ungoogled-chromium/build/src/uc_staging/depot_tools/.patched" ]; then
        echo -e "${GREEN}✓${NC} Applying depot_tools Python 3.14 fix..."
        "$ROOT_DIR/build/tools/fix_depot_tools.sh"
    fi
fi

# Run ungoogled-chromium build (applies our patches automatically)
echo -e "${GREEN}✓${NC} Starting ungoogled-chromium build..."
echo -e "  This will apply ~150 ungoogled-chromium patches"
echo -e "  Plus our custom patches from /patches/series"
echo ""

cd "$ROOT_DIR/ungoogled-chromium"
./build.sh "$@"

echo ""
echo -e "${GREEN}${BOLD}✨ Build Complete!${NC}"
echo ""
echo -e "${BOLD}Browser location:${NC}"
echo -e "  $ROOT_DIR/ungoogled-chromium/build/src/out/Default/Chromium.app"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. Apply branding: ./features/branding/apply.sh"
echo -e "  2. Test browser: open ungoogled-chromium/build/src/out/Default/Chromium.app"
echo ""
