#!/bin/bash
# Apply BaseOne branding to Chromium source
# Company: BaseCode LLC
# Product: BaseOne
# Bundle ID: al.base.one

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="/Volumes/External/BaseChrome/ungoogled-chromium/build/src"

echo "========================================="
echo "Applying BaseOne Branding"
echo "========================================="
echo ""
echo "Company: BaseCode LLC"
echo "Product: BaseOne"
echo "Bundle ID: al.base.one"
echo "Source: $SRC_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Source directory not found: $SRC_DIR"
    exit 1
fi

cd "$SRC_DIR"

# Check if we're in a git repo (chromium source should be)
if [ ! -d ".git" ]; then
    echo "WARNING: Not a git repository. Continuing anyway..."
fi

# Find all .grd and .grdp files in chrome/app
GRD_FILES=$(find chrome/app -name "*.grd" -o -name "*.grdp" 2>/dev/null)

if [ -z "$GRD_FILES" ]; then
    echo "ERROR: No .grd/.grdp files found in chrome/app"
    exit 1
fi

echo "Found resource files to update:"
echo "$GRD_FILES" | head -5
echo "... ($(echo "$GRD_FILES" | wc -l | tr -d ' ') files total)"
echo ""

# Backup files before modification
echo "Creating backups..."
for file in $GRD_FILES; do
    if [ -f "$file" ] && [ ! -f "$file.bak" ]; then
        cp "$file" "$file.bak"
    fi
done

# Apply version update
echo "1. Updating version information..."
BASEONE_VERSION=$(cat "$BASE_DIR/VERSION" 2>/dev/null || echo "0.1.0")
CHROMIUM_VERSION=$(cat "$SRC_DIR/chrome/VERSION" 2>/dev/null | grep -E "MAJOR|MINOR|BUILD|PATCH" | tr '\n' '.' | sed 's/MAJOR=//;s/MINOR=//;s/BUILD=//;s/PATCH=//;s/\.\././g;s/\.$//')

echo "   BaseOne version: $BASEONE_VERSION"
echo "   Chromium version: $CHROMIUM_VERSION"

# Backup original VERSION file
if [ ! -f "$SRC_DIR/chrome/VERSION.bak" ]; then
    cp "$SRC_DIR/chrome/VERSION" "$SRC_DIR/chrome/VERSION.bak"
fi

# Update VERSION file with BaseOne version
# Parse BaseOne version
if [[ "$BASEONE_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    BUILD="${BASH_REMATCH[3]}"
    PATCH="0"

    cat > "$SRC_DIR/chrome/VERSION" << EOF
MAJOR=$MAJOR
MINOR=$MINOR
BUILD=$BUILD
PATCH=$PATCH
EOF

    echo "   Updated chrome/VERSION with BaseOne version $BASEONE_VERSION"
else
    echo "   WARNING: Invalid BaseOne version format, keeping Chromium version"
fi
echo ""

# Apply string replacements
echo "2. Applying branding replacements..."
echo ""

# Count replacements
TOTAL=0

# Replace "Chromium" with "BaseOne" (case-sensitive, preserves XML)
echo "   Replacing 'Chromium' → 'BaseOne'..."
for file in $GRD_FILES; do
    if [ -f "$file" ]; then
        COUNT=$(grep -o "Chromium" "$file" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$COUNT" -gt 0 ]; then
            sed -i '' 's/Chromium/BaseOne/g' "$file"
            echo "   $file: $COUNT replacements"
            TOTAL=$((TOTAL + COUNT))
        fi
    fi
done

echo "   Total: $TOTAL replacements"
echo ""

# Update copyright strings
echo "3. Updating copyright strings with BaseCode LLC..."
COUNT=0
for file in $GRD_FILES; do
    if [ -f "$file" ]; then
        # Replace "The Chromium Authors" with "BaseCode LLC. Based on Chromium, Copyright The Chromium Authors"
        if grep -q "The Chromium Authors" "$file" 2>/dev/null; then
            sed -i '' 's/Copyright © [0-9]* The Chromium Authors/Copyright © 2025 BaseCode LLC. Based on Chromium, Copyright The Chromium Authors/g' "$file"
            sed -i '' 's/Copyright [0-9]* The Chromium Authors/Copyright 2025 BaseCode LLC. Based on Chromium, Copyright The Chromium Authors/g' "$file"
            sed -i '' 's/The Chromium Authors/BaseCode LLC/g' "$file"
            COUNT=$((COUNT + 1))
            echo "   $file"
        fi
    fi
done
echo "   Total: $COUNT files updated"
echo ""

# Apply icon branding
echo "4. Replacing app icons with BaseOne icons..."
ICON_SRC="$BASE_DIR/features/branding/icons"
ICON_DST="$SRC_DIR/chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset"

if [ ! -d "$ICON_SRC" ]; then
    echo "   WARNING: Icon source directory not found: $ICON_SRC"
else
    # Generate 64px icon if it doesn't exist
    if [ ! -f "$ICON_SRC/base_icon_64.png" ]; then
        echo "   Generating 64px icon..."
        sips -z 64 64 "$ICON_SRC/base_icon_128.png" --out "$ICON_SRC/base_icon_64.png" >/dev/null 2>&1
    fi

    # Backup original icons
    if [ -d "$ICON_DST" ] && [ ! -f "$ICON_DST/.backup_done" ]; then
        echo "   Backing up original icons..."
        cp -r "$ICON_DST" "$ICON_DST.bak"
        touch "$ICON_DST/.backup_done"
    fi

    # Copy BaseOne icons
    if [ -d "$ICON_DST" ]; then
        echo "   Copying BaseOne icons..."
        cp "$ICON_SRC/base_icon_16.png" "$ICON_DST/appicon_16.png"
        cp "$ICON_SRC/base_icon_32.png" "$ICON_DST/appicon_32.png"
        cp "$ICON_SRC/base_icon_64.png" "$ICON_DST/appicon_64.png"
        cp "$ICON_SRC/base_icon_128.png" "$ICON_DST/appicon_128.png"
        cp "$ICON_SRC/base_icon_256.png" "$ICON_DST/appicon_256.png"
        cp "$ICON_SRC/base_icon_512.png" "$ICON_DST/appicon_512.png"
        cp "$ICON_SRC/base_icon_1024.png" "$ICON_DST/appicon_1024.png"
        echo "   7 icon files copied"
    else
        echo "   WARNING: Icon destination not found: $ICON_DST"
    fi

    # Copy app.icns for system-level icons (Dock, Finder, etc.)
    ICNS_DST="$SRC_DIR/chrome/app/theme/chromium/mac/app.icns"
    if [ -f "$ICON_SRC/app.icns" ]; then
        echo "   Copying BaseOne app.icns..."
        cp "$ICON_SRC/app.icns" "$ICNS_DST"
        echo "   app.icns copied"
    else
        echo "   WARNING: app.icns not found: $ICON_SRC/app.icns"
    fi
fi
echo ""

# Copy product_logo_32.png (needed for chrome://theme/current-channel-logo)
echo "5. Copying product_logo_32.png for theme system..."
if [ -f "$ICON_SRC/base_icon_32.png" ]; then
    cp "$ICON_SRC/base_icon_32.png" "$SRC_DIR/chrome/app/theme/chromium/product_logo_32.png"
    echo "   product_logo_32.png copied (needed for chrome://theme/current-channel-logo)"
else
    echo "   WARNING: base_icon_32.png not found"
fi
echo ""

# Copy Linux product logos
echo "6. Copying Linux product logos..."
if [ -d "$SRC_DIR/chrome/app/theme/chromium/linux" ]; then
    cp "$ICON_SRC/base_icon_32.png" "$SRC_DIR/chrome/app/theme/chromium/linux/product_logo_24.png"
    cp "$ICON_SRC/base_icon_64.png" "$SRC_DIR/chrome/app/theme/chromium/linux/product_logo_48.png"
    cp "$ICON_SRC/base_icon_64.png" "$SRC_DIR/chrome/app/theme/chromium/linux/product_logo_64.png"
    cp "$ICON_SRC/base_icon_128.png" "$SRC_DIR/chrome/app/theme/chromium/linux/product_logo_128.png"
    cp "$ICON_SRC/base_icon_256.png" "$SRC_DIR/chrome/app/theme/chromium/linux/product_logo_256.png"
    echo "   5 Linux product logos copied"
fi
if [ -d "$SRC_DIR/chrome/app/theme/default_100_percent/chromium/linux" ]; then
    cp "$ICON_SRC/base_icon_16.png" "$SRC_DIR/chrome/app/theme/default_100_percent/chromium/linux/product_logo_16.png"
    cp "$ICON_SRC/base_icon_32.png" "$SRC_DIR/chrome/app/theme/default_100_percent/chromium/linux/product_logo_32.png"
    echo "   2 Linux 100% scale product logos copied"
fi
echo ""

# Show summary
echo "========================================="
echo "Branding Applied Successfully"
echo "========================================="
echo ""
echo "Summary:"
echo "- Product name: $TOTAL instances of 'Chromium' → 'BaseOne'"
echo "- Copyright: $COUNT files updated with BaseCode LLC"
echo "- macOS icons: 7 PNG sizes + app.icns replaced with BaseOne branding"
echo "- Theme logos: product_logo_32.png + 7 Linux product logos replaced"
echo ""
echo "Files modified:"
git diff --name-only chrome/app/ 2>/dev/null || find chrome/app -name "*.grd" -newer chrome/app/*.grd.bak 2>/dev/null | head -10
echo ""
echo "Next steps:"
echo "1. Review changes: cd $SRC_DIR && git diff chrome/app/"
echo "2. Generate patch: cd $BASE_DIR && ./scripts/generate_branding_patch.sh"
echo "3. Build: cd $BASE_DIR && ./scripts/6_build_incremental.sh"
echo ""
