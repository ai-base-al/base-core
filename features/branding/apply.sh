#!/bin/bash
# Apply Base Dev branding to Chromium

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

source "$SCRIPT_DIR/config.sh"

echo ""
echo -e "${CYAN}${BOLD}════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}   🎨 Applying Base Dev Branding${NC}"
echo -e "${CYAN}${BOLD}════════════════════════════════════════${NC}"
echo ""

# Check if source exists
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${YELLOW}⚠️  Chromium source not found!${NC}"
    echo -e "${DIM}Build first: ./run/5_build_macos.sh${NC}"
    exit 1
fi

echo -e "${BOLD}📝 Branding Configuration:${NC}"
echo -e "  Product Name: ${CYAN}$PRODUCT_NAME${NC}"
echo -e "  Short Name:   ${CYAN}$PRODUCT_SHORT_NAME${NC}"
echo -e "  Bundle ID:    ${CYAN}$BUNDLE_ID${NC}"
echo ""

# 1. Update BRANDING file
echo -e "${GREEN}✓${NC} Updating BRANDING file..."
BRANDING_FILE="$SRC_DIR/chrome/app/theme/chromium/BRANDING"

if [ -f "$BRANDING_FILE" ]; then
    # Backup original
    if [ ! -f "$BRANDING_FILE.orig" ]; then
        cp "$BRANDING_FILE" "$BRANDING_FILE.orig"
    fi

    cat > "$BRANDING_FILE" << EOF
COMPANY_FULLNAME=$COMPANY_NAME
COMPANY_SHORTNAME=$COMPANY_NAME
PRODUCT_FULLNAME=$PRODUCT_FULLNAME
PRODUCT_SHORTNAME=$PRODUCT_SHORT_NAME
PRODUCT_INSTALLER_FULLNAME=$PRODUCT_FULLNAME Installer
PRODUCT_INSTALLER_SHORTNAME=$PRODUCT_SHORT_NAME Installer
CHROMIUM_DISTRO=$PRODUCT_NAME
MAC_BUNDLE_ID=$BUNDLE_ID
MAC_CREATOR_CODE=Base
ATSUI_FONTNAME=$PRODUCT_SHORT_NAME
EOF
    echo -e "  ${DIM}→ $BRANDING_FILE${NC}"
else
    echo -e "  ${YELLOW}⚠️  BRANDING file not found${NC}"
fi

# 2. Update app name in build files
echo -e "${GREEN}✓${NC} Updating app name in GN files..."

# Update chrome/BUILD.gn
CHROME_BUILD_GN="$SRC_DIR/chrome/BUILD.gn"
if [ -f "$CHROME_BUILD_GN" ]; then
    if [ ! -f "$CHROME_BUILD_GN.orig" ]; then
        cp "$CHROME_BUILD_GN" "$CHROME_BUILD_GN.orig"
    fi

    # Update product_name in BUILD.gn
    sed -i '' "s/product_name = \"Chromium\"/product_name = \"$PRODUCT_NAME\"/g" "$CHROME_BUILD_GN" || true
    echo -e "  ${DIM}→ chrome/BUILD.gn${NC}"
fi

# 3. Update Info.plist template
echo -e "${GREEN}✓${NC} Updating Info.plist template..."
PLIST_TEMPLATE="$SRC_DIR/chrome/app/framework/Info.plist"
if [ -f "$PLIST_TEMPLATE" ]; then
    if [ ! -f "$PLIST_TEMPLATE.orig" ]; then
        cp "$PLIST_TEMPLATE" "$PLIST_TEMPLATE.orig"
    fi

    sed -i '' "s/org\.chromium\.Chromium/$BUNDLE_ID/g" "$PLIST_TEMPLATE" || true
    sed -i '' "s/Chromium/$PRODUCT_NAME/g" "$PLIST_TEMPLATE" || true
    echo -e "  ${DIM}→ chrome/app/framework/Info.plist${NC}"
fi

# 4. Update main app Info.plist
MAIN_PLIST="$SRC_DIR/chrome/app/app-Info.plist"
if [ -f "$MAIN_PLIST" ]; then
    if [ ! -f "$MAIN_PLIST.orig" ]; then
        cp "$MAIN_PLIST" "$MAIN_PLIST.orig"
    fi

    sed -i '' "s/org\.chromium\.Chromium/$BUNDLE_ID/g" "$MAIN_PLIST" || true
    sed -i '' "s/Chromium/$PRODUCT_NAME/g" "$MAIN_PLIST" || true
    echo -e "  ${DIM}→ chrome/app/app-Info.plist${NC}"
fi

# 5. Update product strings
echo -e "${GREEN}✓${NC} Updating product strings..."
STRINGS_FILE="$SRC_DIR/chrome/app/chromium_strings.grd"
if [ -f "$STRINGS_FILE" ]; then
    if [ ! -f "$STRINGS_FILE.orig" ]; then
        cp "$STRINGS_FILE" "$STRINGS_FILE.orig"
    fi

    sed -i '' "s/>Chromium</>$PRODUCT_NAME</g" "$STRINGS_FILE" || true
    echo -e "  ${DIM}→ chrome/app/chromium_strings.grd${NC}"
fi

# 6. Generate fresh icons from SVG sources
echo -e "${GREEN}✓${NC} Generating icons from SVG sources..."
if [ -x "$SCRIPT_DIR/scripts/generate_icons.sh" ]; then
    "$SCRIPT_DIR/scripts/generate_icons.sh"
else
    echo -e "  ${YELLOW}⚠️  Icon generation script not found or not executable${NC}"
fi

# 6b. Replace icons with Base Dev branding
echo -e "${GREEN}✓${NC} Replacing app icons..."
ICONS_SRC="$SCRIPT_DIR/icons"
ICON_COUNT=0

if [ -d "$ICONS_SRC" ]; then
    # Replace main app icon (app.icns)
    APP_ICON_DEST="$SRC_DIR/chrome/app/theme/chromium/mac/app.icns"
    if [ -f "$ICONS_SRC/app.icns" ] && [ -f "$APP_ICON_DEST" ]; then
        if [ ! -f "$APP_ICON_DEST.orig" ]; then
            cp "$APP_ICON_DEST" "$APP_ICON_DEST.orig"
        fi
        cp "$ICONS_SRC/app.icns" "$APP_ICON_DEST"
        echo -e "  ${DIM}→ Replaced app.icns${NC}"
        ((ICON_COUNT++))
    fi

    # Replace document icon if exists
    DOC_ICON_DEST="$SRC_DIR/chrome/app/theme/chromium/mac/document.icns"
    if [ -f "$ICONS_SRC/document.icns" ] && [ -f "$DOC_ICON_DEST" ]; then
        if [ ! -f "$DOC_ICON_DEST.orig" ]; then
            cp "$DOC_ICON_DEST" "$DOC_ICON_DEST.orig"
        fi
        cp "$ICONS_SRC/document.icns" "$DOC_ICON_DEST"
        echo -e "  ${DIM}→ Replaced document.icns${NC}"
        ((ICON_COUNT++))
    fi

    # Replace product logo PNGs
    PRODUCT_LOGO_DIR="$SRC_DIR/chrome/app/theme/chromium"
    if [ -f "$ICONS_SRC/product_logo_name_22.png" ]; then
        for logo_file in product_logo_name_22.png product_logo_name_22@2x.png \
                         product_logo_name_22_white.png product_logo_name_22_white@2x.png; do
            if [ -f "$ICONS_SRC/$logo_file" ]; then
                DEST="$PRODUCT_LOGO_DIR/$logo_file"
                if [ -f "$DEST" ]; then
                    if [ ! -f "$DEST.orig" ]; then
                        cp "$DEST" "$DEST.orig"
                    fi
                    cp "$ICONS_SRC/$logo_file" "$DEST"
                    echo -e "  ${DIM}→ Replaced $logo_file${NC}"
                    ((ICON_COUNT++))
                fi
            fi
        done
    fi

    echo -e "  ${GREEN}✓${NC} Replaced $ICON_COUNT icon files"
else
    echo -e "  ${YELLOW}⚠️  Icon directory not found: $ICONS_SRC${NC}"
    echo -e "  ${DIM}Using default Chromium icons${NC}"
fi

# 7. Create patch file for reference
echo -e "${GREEN}✓${NC} Creating patch file..."
cat > "$SCRIPT_DIR/patches/base-dev-branding.patch" << 'EOFPATCH'
# Base Dev Branding Patch
# This patch is auto-generated and documents the branding changes
# Apply script handles the actual changes

diff --git a/chrome/app/theme/chromium/BRANDING b/chrome/app/theme/chromium/BRANDING
--- a/chrome/app/theme/chromium/BRANDING
+++ b/chrome/app/theme/chromium/BRANDING
@@ -1,7 +1,7 @@
-COMPANY_FULLNAME=The Chromium Authors
-COMPANY_SHORTNAME=The Chromium Authors
-PRODUCT_FULLNAME=Chromium
-PRODUCT_SHORTNAME=Chromium
+COMPANY_FULLNAME=Base
+COMPANY_SHORTNAME=Base
+PRODUCT_FULLNAME=Base Dev Browser
+PRODUCT_SHORTNAME=Base
EOFPATCH

echo ""
echo -e "${GREEN}${BOLD}✨ Branding Applied Successfully!${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo -e "  1. Build with: ${CYAN}./run/5_build_macos.sh -d${NC}"
echo -e "  2. Build time: ${DIM}~15-30 minutes (incremental)${NC}"
echo -e "  3. Result: ${CYAN}Base Dev.app${NC} in build/src/out/Default/"
echo ""
echo -e "${BOLD}To Rollback:${NC}"
echo -e "  ${CYAN}./features/branding/rollback.sh${NC}"
echo ""