# BaseOne Branding Guide

Complete guide for applying BaseOne branding to the Chromium source code.

## Overview

BaseOne branding consists of two main components:
1. **String replacements** - Changing "Chromium" to "BaseOne" throughout the UI
2. **Icon replacements** - Replacing Chromium icons with BaseOne icons

Both are applied automatically by `scripts/apply_baseone_branding.sh`, which is called by `scripts/apply_base.sh`.

## Quick Start

```bash
cd /Volumes/External/BaseChrome/base-core
./scripts/apply_base.sh
./scripts/build_incremental.sh
```

## Branding Components

### 1. String Replacements

#### What Gets Changed

All `.grd` and `.grdp` files in `chrome/app/` are modified:
- "Chromium" → "BaseOne"
- "The Chromium Authors" → "BaseCode LLC"
- Copyright notices updated to include BaseCode LLC attribution

#### Files Modified

Main string resource files:
```
chrome/app/chromium_strings.grd
chrome/app/settings_chromium_strings.grdp
chrome/app/generated_resources.grd
chrome/app/google_chrome_strings.grd
chrome/app/settings_strings.grdp
```

#### How It Works

The `apply_baseone_branding.sh` script uses `sed` to replace strings:

```bash
# Replace Chromium with BaseOne
sed -i '' 's/Chromium/BaseOne/g' "$file"

# Update copyright
sed -i '' 's/The Chromium Authors/BaseCode LLC/g' "$file"
```

#### Verifying String Changes

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src

# Check for remaining "Chromium" references
grep -r "Chromium" chrome/app/*.grd chrome/app/*.grdp

# Check copyright changes
grep -r "BaseCode LLC" chrome/app/*.grd chrome/app/*.grdp
```

### 2. Icon Replacements

#### Icon Inventory

BaseOne includes the following icon formats:

**Source Icons** (`features/branding/icons/`):
- base_icon_16.png (16x16)
- base_icon_32.png (32x32)
- base_icon_64.png (64x64) - auto-generated if missing
- base_icon_128.png (128x128)
- base_icon_256.png (256x256)
- base_icon_512.png (512x512)
- base_icon_1024.png (1024x1024)
- app.icns (macOS icon bundle)

**Destination Locations**:

| Source File | Destination | Purpose |
|-------------|-------------|---------|
| base_icon_16.png | appicon_16.png | macOS app icon 16px |
| base_icon_32.png | appicon_32.png | macOS app icon 32px |
| base_icon_64.png | appicon_64.png | macOS app icon 64px |
| base_icon_128.png | appicon_128.png | macOS app icon 128px |
| base_icon_256.png | appicon_256.png | macOS app icon 256px |
| base_icon_512.png | appicon_512.png | macOS app icon 512px |
| base_icon_1024.png | appicon_1024.png | macOS app icon 1024px |
| app.icns | app.icns | System icons (Dock, Finder) |
| base_icon_32.png | product_logo_32.png | Theme system logo |

#### macOS Icons (Assets.xcassets)

Location: `chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset/`

These icons are used by the macOS app bundle:
```
AppIcon.appiconset/
├── appicon_16.png    # 16x16 - Retina display
├── appicon_32.png    # 32x32 - Retina display
├── appicon_64.png    # 64x64 - Retina display
├── appicon_128.png   # 128x128 - Standard + Retina
├── appicon_256.png   # 256x256 - Standard + Retina
├── appicon_512.png   # 512x512 - Standard + Retina
└── appicon_1024.png  # 1024x1024 - Retina display
```

#### System-Level Icons (app.icns)

Location: `chrome/app/theme/chromium/mac/app.icns`

The `.icns` file is a macOS icon bundle containing multiple resolutions. This is what macOS uses for:
- Dock icon
- Finder icon
- Spotlight search results
- Quick Look previews
- App switcher (Cmd+Tab)

#### Theme Logo (product_logo_32.png)

Location: `chrome/app/theme/chromium/product_logo_32.png`

Used by the theme system for:
- chrome://theme/current-channel-logo
- About page logo
- Settings page logo
- Internal chrome:// pages

#### Linux Icons (if building for Linux)

Location: `chrome/app/theme/chromium/linux/`

Product logos for Linux platforms:
- product_logo_24.png (24x24)
- product_logo_48.png (48x48)
- product_logo_64.png (64x64)
- product_logo_128.png (128x128)
- product_logo_256.png (256x256)

#### How Icon Replacement Works

The `apply_baseone_branding.sh` script:

1. **Checks for source icons**:
   ```bash
   ICON_SRC="$BASE_DIR/features/branding/icons"
   ```

2. **Generates missing sizes** (e.g., 64px):
   ```bash
   sips -z 64 64 "$ICON_SRC/base_icon_128.png" \
        --out "$ICON_SRC/base_icon_64.png"
   ```

3. **Backs up original icons** (first time only):
   ```bash
   cp -r "$ICON_DST" "$ICON_DST.bak"
   touch "$ICON_DST/.backup_done"
   ```

4. **Copies BaseOne icons**:
   ```bash
   cp "$ICON_SRC/base_icon_16.png" "$ICON_DST/appicon_16.png"
   cp "$ICON_SRC/base_icon_32.png" "$ICON_DST/appicon_32.png"
   # ... and so on for all sizes
   ```

5. **Copies system icon**:
   ```bash
   cp "$ICON_SRC/app.icns" \
      "$SRC_DIR/chrome/app/theme/chromium/mac/app.icns"
   ```

6. **Copies theme logo**:
   ```bash
   cp "$ICON_SRC/base_icon_32.png" \
      "$SRC_DIR/chrome/app/theme/chromium/product_logo_32.png"
   ```

#### Verifying Icon Changes

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src

# Check macOS app icons
ls -lh chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset/

# Check system icon
ls -lh chrome/app/theme/chromium/mac/app.icns

# Check theme logo
ls -lh chrome/app/theme/chromium/product_logo_32.png

# Verify icon sizes
file chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset/appicon_*.png
```

## Creating BaseOne Icons

### Requirements

- Source image: High resolution (at least 1024x1024)
- Format: PNG with transparency
- Style: Consistent with BaseOne branding
- Colors: BaseOne brand colors

### Generating Icon Set

If you have a single high-resolution source (e.g., `source.png` at 2048x2048):

```bash
cd /Volumes/External/BaseChrome/base-core/features/branding/icons

# Generate all required sizes
sips -z 16 16 source.png --out base_icon_16.png
sips -z 32 32 source.png --out base_icon_32.png
sips -z 64 64 source.png --out base_icon_64.png
sips -z 128 128 source.png --out base_icon_128.png
sips -z 256 256 source.png --out base_icon_256.png
sips -z 512 512 source.png --out base_icon_512.png
sips -z 1024 1024 source.png --out base_icon_1024.png
```

### Creating app.icns

The `.icns` file must be created using the `iconutil` tool:

```bash
# Create iconset directory
mkdir BaseOne.iconset

# Copy icons with specific naming
cp base_icon_16.png BaseOne.iconset/icon_16x16.png
cp base_icon_32.png BaseOne.iconset/icon_16x16@2x.png
cp base_icon_32.png BaseOne.iconset/icon_32x32.png
cp base_icon_64.png BaseOne.iconset/icon_32x32@2x.png
cp base_icon_128.png BaseOne.iconset/icon_128x128.png
cp base_icon_256.png BaseOne.iconset/icon_128x128@2x.png
cp base_icon_256.png BaseOne.iconset/icon_256x256.png
cp base_icon_512.png BaseOne.iconset/icon_256x256@2x.png
cp base_icon_512.png BaseOne.iconset/icon_512x512.png
cp base_icon_1024.png BaseOne.iconset/icon_512x512@2x.png

# Convert to .icns
iconutil -c icns BaseOne.iconset -o app.icns

# Clean up
rm -rf BaseOne.iconset
```

## Manual Branding Application

If you need to apply branding manually (for testing or debugging):

### Apply Strings Only

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src

# Find all .grd and .grdp files
find chrome/app -name "*.grd" -o -name "*.grdp" > /tmp/grd_files.txt

# Replace Chromium with BaseOne
while read file; do
  sed -i '' 's/Chromium/BaseOne/g' "$file"
done < /tmp/grd_files.txt

# Update copyright
while read file; do
  sed -i '' 's/The Chromium Authors/BaseCode LLC/g' "$file"
done < /tmp/grd_files.txt
```

### Apply Icons Only

```bash
cd /Volumes/External/BaseChrome/base-core

# Just copy icons without running full branding script
ICON_SRC="features/branding/icons"
ICON_DST="/Volumes/External/BaseChrome/ungoogled-chromium/build/src/chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset"

cp "$ICON_SRC/base_icon_16.png" "$ICON_DST/appicon_16.png"
cp "$ICON_SRC/base_icon_32.png" "$ICON_DST/appicon_32.png"
cp "$ICON_SRC/base_icon_64.png" "$ICON_DST/appicon_64.png"
cp "$ICON_SRC/base_icon_128.png" "$ICON_DST/appicon_128.png"
cp "$ICON_SRC/base_icon_256.png" "$ICON_DST/appicon_256.png"
cp "$ICON_SRC/base_icon_512.png" "$ICON_DST/appicon_512.png"
cp "$ICON_SRC/base_icon_1024.png" "$ICON_DST/appicon_1024.png"
```

## After Branding

### Rebuild

After applying branding, rebuild the browser:

```bash
cd /Volumes/External/BaseChrome/base-core

# Incremental build (10-30 minutes)
./scripts/build_incremental.sh
```

### Test the Branding

1. **Open the built app**:
   ```bash
   open /Volumes/External/BaseChrome/ungoogled-chromium/build/src/out/Default/BaseOne.app
   ```

2. **Check UI branding**:
   - Open About page: `chrome://about` or Menu → About BaseOne
   - Check Settings: `chrome://settings`
   - Look for "BaseOne" in all UI text
   - Verify no "Chromium" references remain

3. **Check icon branding**:
   - Check Dock icon (should show BaseOne icon)
   - Check app icon in Finder
   - Check About page logo
   - Check Settings page header

4. **Check copyright**:
   - About page should show "BaseCode LLC"
   - Copyright text should include BaseCode LLC attribution

### Common Issues

#### Icons not showing

**Problem**: Icons are copied but don't appear in the built app.

**Solution**:
1. Check that icons were actually copied:
   ```bash
   ls -lh /Volumes/External/BaseChrome/ungoogled-chromium/build/src/chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset/
   ```

2. Rebuild completely:
   ```bash
   cd /Volumes/External/BaseChrome/base-core
   ./scripts/build_incremental.sh
   ```

3. Clear Finder icon cache (macOS):
   ```bash
   sudo rm -rf /Library/Caches/com.apple.iconservices.store
   sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \;
   killall Dock
   killall Finder
   ```

#### Strings not replaced

**Problem**: Still seeing "Chromium" in the UI.

**Solution**:
1. Verify string replacements were applied:
   ```bash
   cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src
   grep -r "Chromium" chrome/app/*.grd chrome/app/*.grdp
   ```

2. If "Chromium" still appears, reapply branding:
   ```bash
   cd /Volumes/External/BaseChrome/base-core
   ./scripts/apply_base.sh
   ```

3. Rebuild:
   ```bash
   ./scripts/build_incremental.sh
   ```

#### Copyright text incorrect

**Problem**: Copyright still shows "The Chromium Authors" instead of "BaseCode LLC".

**Solution**:
1. Check copyright in source files:
   ```bash
   cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src
   grep -r "BaseCode LLC" chrome/app/*.grd chrome/app/*.grdp
   ```

2. If not present, reapply branding:
   ```bash
   cd /Volumes/External/BaseChrome/base-core
   ./scripts/apply_baseone_branding.sh
   ```

## Creating Branding Patches

If you want to distribute branding as a patch file:

### Generate Icon Branding Patch

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src

# Stage icon changes
git add chrome/app/theme/

# Create patch
git diff --staged --binary > /Volumes/External/BaseChrome/base-core/patches/baseone-icon-branding.patch
```

### Generate String Branding Patch

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src

# Stage string changes
git add chrome/app/*.grd chrome/app/*.grdp

# Create patch
git diff --staged > /Volumes/External/BaseChrome/base-core/patches/baseone-string-branding.patch
```

### Add to Series File

```bash
cd /Volumes/External/BaseChrome/base-core

# Edit patches/series
cat >> patches/series << EOF

# Branding patches
baseone-string-branding.patch
baseone-icon-branding.patch
EOF
```

## Automation

The branding process is fully automated through `scripts/apply_base.sh`:

```bash
#!/bin/bash
# scripts/apply_base.sh

# Step 1: Apply patches from patches/series
# (includes any branding patches)

# Step 2: Run branding script
./scripts/apply_baseone_branding.sh
```

This ensures branding is consistently applied every time you set up or reset the source.

## Summary

- **Strings**: All "Chromium" → "BaseOne" in .grd/.grdp files
- **Copyright**: "The Chromium Authors" → "BaseCode LLC"
- **Icons**: 7 PNG sizes + app.icns + theme logo
- **Script**: `./scripts/apply_baseone_branding.sh` (or use `./scripts/apply_base.sh`)
- **Build**: `./scripts/build_incremental.sh`
- **Test**: Check About page, Settings, Dock icon, Finder icon

## Next Steps

After branding is applied and tested:

1. Create a release: `./scripts/release.sh -v 0.1.0 -c "Release Name"`
2. Package DMG: Included in release script
3. Sign and notarize: Included in release script
4. Publish to GitHub: Included in release script

See `scripts/release.sh` for complete release automation.
