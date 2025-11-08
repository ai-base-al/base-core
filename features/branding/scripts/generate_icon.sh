#!/bin/bash
# Generate Base Dev icon from template
# This creates a simple colored icon placeholder

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_DIR="$SCRIPT_DIR/../icons"

mkdir -p "$ICON_DIR"

echo "Generating Base Dev icon placeholder..."
echo ""
echo "To create custom icons:"
echo "1. Design your icon in sizes: 16x16, 32x32, 128x128, 256x256, 512x512"
echo "2. Save as PNG files in features/branding/icons/"
echo "3. Convert to .icns using:"
echo "   iconutil -c icns icons.iconset"
echo ""
echo "Icon colors suggested:"
echo "  Primary: #4A90E2 (Blue)"
echo "  Accent:  #7B68EE (Purple)"
echo ""
echo "Icon files will be placed in:"
echo "  ungoogled-chromium/build/src/chrome/app/theme/chromium/mac/app.icns"
echo ""

# Create placeholder README
cat > "$ICON_DIR/README.md" << 'EOF'
# Base Dev Icons

Place your custom icons here.

## Required Icon Sizes

For macOS (.icns):
- 16x16
- 16x16@2x (32x32)
- 32x32
- 32x32@2x (64x64)
- 128x128
- 128x128@2x (256x256)
- 256x256
- 256x256@2x (512x512)
- 512x512
- 512x512@2x (1024x1024)

## Creating .icns

1. Create `icons.iconset/` directory
2. Add PNG files with names:
   - icon_16x16.png
   - icon_16x16@2x.png
   - icon_32x32.png
   - icon_32x32@2x.png
   - icon_128x128.png
   - icon_128x128@2x.png
   - icon_256x256.png
   - icon_256x256@2x.png
   - icon_512x512.png
   - icon_512x512@2x.png

3. Convert:
   ```bash
   iconutil -c icns icons.iconset -o app.icns
   ```

4. Copy to source:
   ```bash
   cp app.icns ../../ungoogled-chromium/build/src/chrome/app/theme/chromium/mac/
   ```

## Design Guidelines

**Brand Colors:**
- Primary: #4A90E2 (Blue)
- Accent: #7B68EE (Purple)
- Background: White or transparent

**Style:**
- Modern, minimal
- Clear at small sizes
- Distinct from Chrome/Chromium
- Represents "Base" concept
EOF

echo "Icon directory ready: $ICON_DIR"
echo "See $ICON_DIR/README.md for instructions"