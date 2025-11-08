#!/bin/bash
# Smart string replacement - Replace "Chromium" with "Base Dev" in user-facing strings
# This identifies the RIGHT strings to replace (not internal code references)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

source "$SCRIPT_DIR/../config.sh"

echo ""
echo -e "${CYAN}${BOLD}🔍 Smart String Replacement${NC}"
echo ""
echo -e "${BOLD}Replacing:${NC}"
echo -e "  Chromium → ${CYAN}$PRODUCT_NAME${NC}"
echo -e "  The Chromium Authors → ${CYAN}$COMPANY_NAME${NC}"
echo ""

if [ ! -d "$SRC_DIR" ]; then
    echo -e "${YELLOW}⚠️  Source not found!${NC}"
    exit 1
fi

cd "$SRC_DIR"

# Backup function
backup_file() {
    local file="$1"
    if [ ! -f "$file.brandorig" ]; then
        cp "$file" "$file.brandorig"
    fi
}

# List of user-facing string files to modify
STRING_FILES=(
    "chrome/app/chromium_strings.grd"
    "chrome/app/settings_chromium_strings.grdp"
    "chrome/app/generated_resources.grd"
    "chrome/app/google_chrome_strings.grd"
    "chrome/app/password_manager_ui_strings.grdp"
    "chrome/app/settings_google_chrome_strings.grdp"
    "chrome/app/settings_strings.grdp"
    "chrome/app/shared_settings_strings.grdp"
)

CHANGES=0

echo -e "${GREEN}✓${NC} Processing string files..."
echo ""

for FILE in "${STRING_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        backup_file "$FILE"

        echo -e "  ${DIM}→ $FILE${NC}"

        # Replace user-facing strings ONLY
        # These patterns are safe to replace:

        # 1. Window titles - "Page Title - Chromium" → "Page Title - Base Dev"
        sed -i '' "s/ - Chromium</ - $PRODUCT_NAME</g" "$FILE" && ((CHANGES++))
        sed -i '' "s/>Chromium - />$PRODUCT_NAME - /g" "$FILE" && ((CHANGES++))

        # 2. About box copyright
        # Keep attribution: "Copyright YEAR Base. Based on Chromium, Copyright The Chromium Authors."
        sed -i '' "s/Copyright <ph name=\"YEAR\">{0,date,y}<ex>[0-9]*<\/ex><\/ph> The Chromium Authors\./Copyright <ph name=\"YEAR\">{0,date,y}<ex>2025<\/ex><\/ph> $COMPANY_NAME. Based on Chromium, Copyright The Chromium Authors./g" "$FILE" && ((CHANGES++))

        # 3. Product name in messages - "sign in to Chromium" → "sign in to Base Dev"
        sed -i '' "s/sign in to Chromium/sign in to $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/signed in to Chromium/signed in to $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 4. "Help make Chromium better" → "Help make Base Dev better"
        sed -i '' "s/make Chromium better/make $PRODUCT_NAME better/g" "$FILE" && ((CHANGES++))

        # 5. "About Chromium" menu item
        sed -i '' "s/About &Chromium/About $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/About Chromium/About $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 6. Standalone "Chromium" in UI strings
        sed -i '' "s/>Chromium</>$PRODUCT_NAME</g" "$FILE" && ((CHANGES++))

        # 6. Alt text and descriptions
        sed -i '' "s/Chromium logo/$PRODUCT_NAME logo/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Chromium Enterprise/$PRODUCT_NAME Enterprise/g" "$FILE" && ((CHANGES++))

        # 7. About/Credits attribution - Keep Chromium project credit
        # "Chromium is made possible" → "Base Dev is made possible by the Chromium open source project"
        sed -i '' "s/Chromium is made possible by/$PRODUCT_NAME is made possible by the Chromium open source project and/g" "$FILE" && ((CHANGES++))

        # PHASE 2 REPLACEMENTS - Profile, Data, Sign-out, Additional UI

        # 8. Profile references
        sed -i '' "s/Chromium profile/$PRODUCT_NAME profile/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/your Chromium/your $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/this Chromium/this $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 9. Data references
        sed -i '' "s/Chromium data/$PRODUCT_NAME data/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/from Chromium/from $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 10. Sign-out and session messages
        sed -i '' "s/sign out of Chromium/sign out of $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Sign out of Chromium/Sign out of $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Signing in to Chromium/Signing in to $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 11. Task Manager window title
        sed -i '' "s/Task Manager - Chromium/Task Manager - $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 12. Sync and services
        sed -i '' "s/Chromium Sync/$PRODUCT_NAME Sync/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/sync with Chromium/sync with $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 13. Dialog titles
        sed -i '' "s/Chromium Signin/$PRODUCT_NAME Signin/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Chromium Sign-in/$PRODUCT_NAME Sign-in/g" "$FILE" && ((CHANGES++))

        # 14. Possessive forms
        sed -i '' "s/Chromium's/$PRODUCT_NAME's/g" "$FILE" && ((CHANGES++))

        # 15. Additional window/dialog patterns
        sed -i '' "s/in Chromium/in $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/In Chromium/In $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/to Chromium/to $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 16. Settings and preferences
        sed -i '' "s/Chromium settings/$PRODUCT_NAME settings/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Chromium preferences/$PRODUCT_NAME preferences/g" "$FILE" && ((CHANGES++))

        # 17. Browser name in sentences (careful - exclude attribution)
        # "Use Chromium" but NOT "Chromium open source project"
        sed -i '' "s/use Chromium/use $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Use Chromium/Use $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/on Chromium/on $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # PHASE 3 REPLACEMENTS - Edge cases, descriptions, password manager

        # 18. Relaunch messages
        sed -i '' "s/relaunch Chromium/relaunch $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/Relaunch Chromium/Relaunch $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 19. Before/after Chromium
        sed -i '' "s/before Chromium/before $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/when Chromium/when $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 20. Descriptions (desc attribute) - these guide translators
        sed -i '' "s/desc=\"\([^\"]*\)Chromium \([^\"]*\)\"/desc=\"\1$PRODUCT_NAME \2\"/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/desc=\"\([^\"]*\) Chromium\"/desc=\"\1 $PRODUCT_NAME\"/g" "$FILE" && ((CHANGES++))

        # 21. Default browser and uninstall
        sed -i '' "s/default when Chromium/default when $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/set Chromium/set $PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # 22. Password manager edge cases
        sed -i '' "s/If Chromium finds/If $PRODUCT_NAME finds/g" "$FILE" && ((CHANGES++))
        sed -i '' "s/ChrChromium/$PRODUCT_NAME/g" "$FILE" && ((CHANGES++))

        # DO NOT replace:
        # - "chromium" (lowercase - internal identifiers)
        # - ChromiumOS (different product)
        # - URLs with chromium.org
        # - "Chromium open source project" (attribution)
        # - "Chromium Authors" (attribution)
        # - Code comments
        # - File paths

    else
        echo -e "  ${YELLOW}⚠${NC}  $FILE not found"
    fi
done

echo ""
echo -e "${GREEN}✓${NC} Processed ${BOLD}${#STRING_FILES[@]}${NC} string files"
echo -e "${GREEN}✓${NC} Made ${BOLD}$CHANGES${NC} replacements"
echo ""

# Show preview of changes
echo -e "${BOLD}Preview of changes:${NC}"
echo ""
for FILE in "${STRING_FILES[@]}"; do
    if [ -f "$FILE.brandorig" ]; then
        echo -e "${DIM}$FILE:${NC}"
        diff "$FILE.brandorig" "$FILE" | grep -E "^<|^>" | head -5 || echo "  (no visible changes)"
        echo ""
    fi
done

echo -e "${CYAN}${BOLD}Next Steps:${NC}"
echo -e "  1. Review changes above"
echo -e "  2. Build: ${CYAN}cd $ROOT_DIR && ./run/6_rebuild_only.sh${NC}"
echo -e "  3. Test the rebuilt app"
echo ""
echo -e "${BOLD}To rollback:${NC}"
echo -e "  ${DIM}# Restore all .brandorig files${NC}"
echo -e "  for f in \$(find chrome/app -name '*.brandorig'); do"
echo -e "    mv \"\$f\" \"\${f%.brandorig}\""
echo -e "  done"
echo ""