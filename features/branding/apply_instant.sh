#!/bin/bash
# Instantly apply Base Dev branding to existing Chromium.app
# No rebuild needed!

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/ungoogled-chromium/build/src/out/Default"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

source "$SCRIPT_DIR/config.sh"

echo ""
echo -e "${CYAN}${BOLD}⚡ Instant Branding - No Build!${NC}"
echo ""

# Check if Chromium.app exists
if [ ! -d "$APP_DIR/Chromium.app" ]; then
    echo -e "${YELLOW}⚠️  Chromium.app not found!${NC}"
    echo "Build first: ./run/5_build_macos.sh"
    exit 1
fi

cd "$APP_DIR"

echo -e "${GREEN}✓${NC} Renaming app..."
mv -n "Chromium.app" "Base Dev.app" 2>/dev/null || echo "  Already renamed"

echo -e "${GREEN}✓${NC} Updating Info.plist..."
/usr/libexec/PlistBuddy -c "Set :CFBundleName $PRODUCT_NAME" "Base Dev.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "Base Dev.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $PRODUCT_NAME" "Base Dev.app/Contents/Info.plist" 2>/dev/null || true

echo ""
echo -e "${GREEN}${BOLD}✨ Done in 1 second!${NC}"
echo ""
echo -e "${BOLD}Test:${NC} open \"$APP_DIR/Base Dev.app\""
echo ""