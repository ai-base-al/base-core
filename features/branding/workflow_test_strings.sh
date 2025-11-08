#!/bin/bash
# Systematic workflow: Add strings → Build → Test → Add more

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ITERATION=1

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}    🔄 Systematic String Replacement Workflow${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""

# Function to search for remaining "Chromium" instances
find_remaining_chromium() {
    echo -e "${PURPLE}${BOLD}🔍 Searching for remaining 'Chromium' strings...${NC}"
    echo ""

    cd "$ROOT_DIR/ungoogled-chromium/build/src"

    # Search in user-facing files only
    echo -e "${DIM}Checking string files:${NC}"
    grep -n "Chromium" chrome/app/*.grd chrome/app/*.grdp 2>/dev/null | \
        grep -v "chromium\.org" | \
        grep -v "Chromium Authors" | \
        grep -v "Chromium open source" | \
        grep -v "ChromiumOS" | \
        grep -v "chromium_strings" | \
        grep -v "\.grdp:" | \
        head -20 || echo "  ${GREEN}✓${NC} No obvious user-facing 'Chromium' found!"

    echo ""
}

# Function to build
build_with_strings() {
    echo -e "${GREEN}${BOLD}🔨 Building...${NC}"
    echo ""

    cd "$ROOT_DIR"

    # Try rebuild script first
    if [ -f "run/6_rebuild_only.sh" ]; then
        ./run/6_rebuild_only.sh
    else
        # Fallback to incremental build
        ./run/5_build_macos.sh -d
    fi
}

# Function to test
test_strings() {
    echo ""
    echo -e "${YELLOW}${BOLD}🧪 Testing Changes...${NC}"
    echo ""

    APP_PATH="$ROOT_DIR/ungoogled-chromium/build/src/out/Default/Base Dev.app"

    if [ ! -d "$APP_PATH" ]; then
        echo -e "${YELLOW}⚠️  App not found. Build may have failed.${NC}"
        return 1
    fi

    # Check Info.plist
    echo -e "${DIM}1. Checking bundle name:${NC}"
    BUNDLE_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$APP_PATH/Contents/Info.plist")
    echo -e "   ${CYAN}$BUNDLE_NAME${NC}"

    # Check if app launches
    echo ""
    echo -e "${DIM}2. Testing launch:${NC}"
    echo -e "   Opening Base Dev..."
    open "$APP_PATH"

    sleep 3

    if pgrep -f "Base Dev" > /dev/null; then
        echo -e "   ${GREEN}✓${NC} App is running!"
    else
        echo -e "   ${YELLOW}⚠${NC}  App may need manual approval"
    fi

    echo ""
    echo -e "${BOLD}Manual Testing Checklist:${NC}"
    echo ""
    echo -e "  [ ] Window title shows 'Base Dev'"
    echo -e "  [ ] About menu says 'About Base Dev'"
    echo -e "  [ ] About dialog shows 'Base Dev'"
    echo -e "  [ ] Copyright shows 'BaseCode LLC'"
    echo -e "  [ ] Attribution includes 'Based on Chromium'"
    echo -e "  [ ] No 'Chromium' in visible UI"
    echo ""

    read -p "Does everything look good? (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Workflow iterations
while true; do
    echo -e "${PURPLE}${BOLD}═══ Iteration $ITERATION ═══${NC}"
    echo ""

    case $ITERATION in
        1)
            echo -e "${BOLD}Phase 1: Basic Strings${NC}"
            echo -e "${DIM}(About, Window titles, Copyright)${NC}"
            echo ""

            # Already done!
            echo -e "${GREEN}✓${NC} String replacement already complete"
            echo ""

            read -p "Proceed to build? (y/n): " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                build_with_strings
                if test_strings; then
                    echo -e "${GREEN}✓${NC} Phase 1 complete!"
                    ((ITERATION++))
                else
                    echo -e "${YELLOW}Issues found. Fix and retry.${NC}"
                    exit 1
                fi
            else
                exit 0
            fi
            ;;

        2)
            echo -e "${BOLD}Phase 2: Find Remaining Strings${NC}"
            echo ""

            find_remaining_chromium

            read -p "Found more strings to replace? (y/n): " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                echo ""
                echo -e "${CYAN}Add more replacements to:${NC}"
                echo -e "  ${DIM}features/branding/scripts/replace_strings.sh${NC}"
                echo ""
                echo "Then run this script again."
                exit 0
            else
                echo -e "${GREEN}✓${NC} All done!"
                exit 0
            fi
            ;;

        *)
            echo "Workflow complete!"
            exit 0
            ;;
    esac
done