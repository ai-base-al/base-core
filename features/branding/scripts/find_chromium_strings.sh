#!/bin/bash
# Find all user-facing "Chromium" strings to replace

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../../../ungoogled-chromium/build/src"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}🔍 Finding 'Chromium' in User-Facing Strings${NC}"
echo ""

cd "$SRC_DIR"

# Categories of findings
echo -e "${BOLD}1. About/Menu Strings:${NC}"
grep -rn "About.*Chromium\|Chromium.*About" chrome/app/*.grd* 2>/dev/null | \
    grep -v "ChromiumOS" | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${BOLD}2. Window Titles:${NC}"
grep -rn " - Chromium\|Chromium - " chrome/app/*.grd* 2>/dev/null | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${BOLD}3. Copyright/Attribution:${NC}"
grep -rn "Copyright.*Chromium\|Chromium.*Copyright" chrome/app/*.grd* 2>/dev/null | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${BOLD}4. Sign-in Messages:${NC}"
grep -rn "sign.*Chromium\|Chromium.*sign" chrome/app/*.grd* 2>/dev/null | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${BOLD}5. Help/Support Text:${NC}"
grep -rn "Help.*Chromium\|Chromium.*help" chrome/app/*.grd* 2>/dev/null | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${BOLD}6. Settings Strings:${NC}"
grep -rn ">Chromium<" chrome/app/*.grd* 2>/dev/null | \
    grep -v "chromium.org" | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${BOLD}7. Other Standalone 'Chromium':${NC}"
grep -rn 'desc="[^"]*Chromium' chrome/app/*.grd* 2>/dev/null | \
    grep -v "ChromiumOS" | \
    grep -v "chromium.org" | \
    grep -v "Chromium Authors" | \
    head -10 | \
    sed 's/^/  /' || echo "  ${GREEN}✓${NC} None found"

echo ""
echo -e "${DIM}─────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Summary:${NC}"
echo ""

TOTAL=$(grep -r "Chromium" chrome/app/*.grd* 2>/dev/null | \
    grep -v "chromium.org" | \
    grep -v "ChromiumOS" | \
    grep -v "Chromium Authors" | \
    grep -v "Chromium open source" | \
    wc -l | tr -d ' ')

echo -e "  Total 'Chromium' instances: ${CYAN}$TOTAL${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Some instances should ${BOLD}NOT${NC} be replaced:"
echo -e "  • ${DIM}chromium.org URLs${NC}"
echo -e "  • ${DIM}ChromiumOS (different product)${NC}"
echo -e "  • ${DIM}'Chromium Authors' in attribution${NC}"
echo -e "  • ${DIM}'Chromium open source project'${NC}"
echo ""