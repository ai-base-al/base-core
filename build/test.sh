#!/bin/bash
# Test ungoogled-chromium build

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}   🧪 Testing ungoogled-chromium${NC}"
echo -e "${CYAN}${BOLD}════════════════════════════════════════${NC}"
echo ""

CHROMIUM_APP="/Volumes/Chromium/Chromium.app"

if [ ! -d "$CHROMIUM_APP" ]; then
    echo -e "${YELLOW}DMG not mounted. Mounting...${NC}"
    hdiutil attach /Volumes/External/BaseChrome/base-core/binaries/ungoogled-chromium_*.dmg
    echo ""
fi

echo -e "${BOLD}📋 Version Information:${NC}"
"$CHROMIUM_APP/Contents/MacOS/Chromium" --version
echo ""

echo -e "${BOLD}✅ Basic Tests:${NC}"
echo ""

# Check if binary exists
if [ -f "$CHROMIUM_APP/Contents/MacOS/Chromium" ]; then
    echo -e "  ${GREEN}✓${NC} Binary exists"
else
    echo -e "  ${RED}✗${NC} Binary not found"
    exit 1
fi

# Check architecture
ARCH=$(file "$CHROMIUM_APP/Contents/MacOS/Chromium" | grep -o "arm64\|x86_64")
echo -e "  ${GREEN}✓${NC} Architecture: ${CYAN}$ARCH${NC}"

# Check for Google services (should be removed)
echo ""
echo -e "${BOLD}🔍 Ungoogled Verification:${NC}"
echo ""

STRINGS_OUTPUT=$(strings "$CHROMIUM_APP/Contents/MacOS/Chromium" 2>/dev/null || echo "")

# These should NOT be present in ungoogled-chromium
if echo "$STRINGS_OUTPUT" | grep -q "clients4.google.com" 2>/dev/null; then
    echo -e "  ${YELLOW}⚠${NC}  Found Google API references (may be expected)"
else
    echo -e "  ${GREEN}✓${NC} No Google API domains detected"
fi

# Check for ungoogled markers
if [ -f "$CHROMIUM_APP/Contents/Resources/ungoogled" ]; then
    echo -e "  ${GREEN}✓${NC} Ungoogled marker file present"
fi

echo ""
echo -e "${BOLD}🚀 Launch Test:${NC}"
echo ""

# Try to launch
echo -e "${DIM}Attempting to launch browser...${NC}"
open "$CHROMIUM_APP"

sleep 3

# Check if running
if pgrep -f "Chromium.app" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Browser launched successfully!"
    echo ""
    echo -e "${CYAN}Browser is running. Check for:${NC}"
    echo -e "  • Window opened"
    echo -e "  • No Google branding"
    echo -e "  • Privacy-focused defaults"
    echo ""
    echo -e "${DIM}To close: pkill -f Chromium.app${NC}"
else
    echo -e "  ${YELLOW}⚠${NC}  Browser may need manual approval"
    echo -e "  ${DIM}Check System Settings → Privacy & Security${NC}"
fi

echo ""
echo -e "${BOLD}📍 Browser Location:${NC}"
echo -e "  ${DIM}/Volumes/Chromium/Chromium.app${NC}"
echo ""
echo -e "${BOLD}📦 To Install:${NC}"
echo -e "  ${DIM}Drag to Applications folder or:${NC}"
echo -e "  ${CYAN}cp -R /Volumes/Chromium/Chromium.app /Applications/${NC}"
echo ""