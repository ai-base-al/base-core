#!/usr/bin/env bash
# Generate all BaseOne icons from SVG sources
# Sources: /branding/base.svg (full logo) and /branding/base_browser.svg (icon only)
# Output: /features/branding/icons/ (fresh generated icons)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BRANDING_SRC="$ROOT_DIR/branding"
ICONS_OUTPUT="$SCRIPT_DIR/../icons"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}🎨 Generating BaseOne Icons${NC}"
echo ""

# Check dependencies
if ! command -v rsvg-convert &> /dev/null; then
    echo -e "${YELLOW}⚠️  rsvg-convert not found. Installing...${NC}"
    brew install librsvg
fi

if ! command -v iconutil &> /dev/null; then
    echo -e "${YELLOW}⚠️  iconutil not found (macOS tool)${NC}"
    exit 1
fi

# Check source SVGs
if [ ! -f "$BRANDING_SRC/base_browser.svg" ]; then
    echo -e "${YELLOW}⚠️  Source icon not found: $BRANDING_SRC/base_browser.svg${NC}"
    exit 1
fi

if [ ! -f "$BRANDING_SRC/base.svg" ]; then
    echo -e "${YELLOW}⚠️  Source logo not found: $BRANDING_SRC/base.svg${NC}"
    exit 1
fi

echo -e "${BOLD}Source SVGs:${NC}"
echo -e "  Icon:  ${CYAN}$BRANDING_SRC/base_browser.svg${NC}"
echo -e "  Logo:  ${CYAN}$BRANDING_SRC/base.svg${NC}"
echo ""

# Clean and recreate icons directory
rm -rf "$ICONS_OUTPUT"
mkdir -p "$ICONS_OUTPUT"

# Create iconset directory for macOS .icns generation
ICONSET_DIR="$ICONS_OUTPUT/app.iconset"
mkdir -p "$ICONSET_DIR"

echo -e "${GREEN}✓${NC} Generating app icons from base_browser.svg..."

# Generate all required sizes for .icns from base_browser.svg (icon only, no text)
SIZES=(16 32 128 256 512 1024)
for size in "${SIZES[@]}"; do
    # Normal size
    rsvg-convert -w $size -h $size "$BRANDING_SRC/base_browser.svg" > "$ICONSET_DIR/icon_${size}x${size}.png"
    echo -e "  ${CYAN}→${NC} Generated ${size}x${size}"

    # Also save individual PNGs
    cp "$ICONSET_DIR/icon_${size}x${size}.png" "$ICONS_OUTPUT/base_icon_${size}.png"

    # @2x versions (except 1024 which is already @2x for 512)
    if [ $size -lt 1024 ]; then
        double=$((size * 2))
        rsvg-convert -w $double -h $double "$BRANDING_SRC/base_browser.svg" > "$ICONSET_DIR/icon_${size}x${size}@2x.png"
        echo -e "  ${CYAN}→${NC} Generated ${size}x${size}@2x (${double}x${double})"
    fi
done

# Generate .icns file
echo -e "${GREEN}✓${NC} Creating app.icns..."
iconutil -c icns "$ICONSET_DIR" -o "$ICONS_OUTPUT/app.icns"
rm -rf "$ICONSET_DIR"
echo -e "  ${CYAN}→${NC} app.icns created"

# Generate product logo PNGs from base.svg (full logo with text)
echo -e "${GREEN}✓${NC} Generating product logos from base.svg..."

# Product logo for UI (22px height, used in menus/toolbars)
rsvg-convert -h 22 "$BRANDING_SRC/base.svg" > "$ICONS_OUTPUT/product_logo_name_22.png"
rsvg-convert -h 44 "$BRANDING_SRC/base.svg" > "$ICONS_OUTPUT/product_logo_name_22@2x.png"
echo -e "  ${CYAN}→${NC} Generated product_logo_name_22.png (22px)"
echo -e "  ${CYAN}→${NC} Generated product_logo_name_22@2x.png (44px)"

# White versions for dark backgrounds
# Note: rsvg-convert doesn't change colors, you may need to create white versions manually
# For now, copy the same files (you can edit the SVG to have a white version)
if [ -f "$BRANDING_SRC/base.svg" ]; then
    rsvg-convert -h 22 "$BRANDING_SRC/base.svg" > "$ICONS_OUTPUT/product_logo_name_22_white.png"
    rsvg-convert -h 44 "$BRANDING_SRC/base.svg" > "$ICONS_OUTPUT/product_logo_name_22_white@2x.png"
    echo -e "  ${CYAN}→${NC} Generated white logo variants"
else
    # Fallback: copy regular versions
    cp "$ICONS_OUTPUT/product_logo_name_22.png" "$ICONS_OUTPUT/product_logo_name_22_white.png"
    cp "$ICONS_OUTPUT/product_logo_name_22@2x.png" "$ICONS_OUTPUT/product_logo_name_22_white@2x.png"
    echo -e "  ${YELLOW}ℹ${NC}  No base_white.svg found, using regular logo for white variants"
fi

# Copy source SVG for reference
cp "$BRANDING_SRC/base_browser.svg" "$ICONS_OUTPUT/base_browser.svg"

echo ""
echo -e "${GREEN}${BOLD}✨ Icon Generation Complete!${NC}"
echo ""
echo -e "${BOLD}Generated files:${NC}"
echo -e "  Main icon:     ${CYAN}app.icns${NC}"
echo -e "  PNG icons:     ${CYAN}base_icon_*.png${NC} (16, 32, 128, 256, 512, 1024)"
echo -e "  Product logos: ${CYAN}product_logo_name_22*.png${NC}"
echo ""
echo -e "${BOLD}Output directory:${NC}"
echo -e "  ${CYAN}$ICONS_OUTPUT${NC}"
echo ""
echo -e "${BOLD}Next step:${NC}"
echo -e "  Run ${CYAN}./features/branding/apply.sh${NC} to apply these icons to the build"
echo ""
