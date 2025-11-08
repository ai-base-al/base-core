#!/usr/bin/env bash
# Base Chrome - Incremental Rebuild
# Only recompiles changed files (10-30 min vs 2-4 hours)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}Base Chrome - Incremental Rebuild${NC}"
echo ""

# Check if source exists
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${YELLOW}⚠️  Source not found. Run full build first:${NC}"
    echo -e "  ./build/build.sh"
    exit 1
fi

# Check if already configured
if [ ! -f "$SRC_DIR/out/Default/args.gn" ]; then
    echo -e "${YELLOW}⚠️  Build not configured. Run full build first:${NC}"
    echo -e "  ./build/build.sh -d"
    exit 1
fi

cd "$SRC_DIR"

echo -e "${BOLD}Building in:${NC} ${DIM}$SRC_DIR${NC}"
echo ""

# Regenerate build files (in case patches changed)
echo -e "${GREEN}✓${NC} Regenerating build files..."
./buildtools/mac/gn gen out/Default --fail-on-unused-args

echo ""
echo -e "${GREEN}✓${NC} Building chrome..."
echo -e "${DIM}This will only recompile changed files...${NC}"
echo ""

# Build with Ninja - shows progress
ninja -C out/Default chrome

echo ""
echo -e "${GREEN}${BOLD}✨ Rebuild Complete!${NC}"
echo ""
echo -e "${BOLD}Browser location:${NC}"
echo -e "  $SRC_DIR/out/Default/Chromium.app"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. Apply branding: ./features/branding/apply.sh"
echo -e "  2. Test browser: open \"$SRC_DIR/out/Default/Chromium.app\""
echo ""
