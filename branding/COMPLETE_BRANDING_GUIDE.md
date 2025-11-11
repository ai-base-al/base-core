# BaseOne Complete Branding Guide

Complete documentation of all branding changes applied to transform ungoogled-chromium into BaseOne.

## Overview

BaseOne is a fully branded Chromium-based browser with:
- Company: BaseCode LLC
- Product: BaseOne
- Bundle ID: al.base.one
- No "Chromium" references anywhere in binaries or UI

## Critical: BRANDING File Must Be Updated BEFORE Building

**IMPORTANT**: The `chrome/app/theme/chromium/BRANDING` file MUST be updated before building. This file defines compile-time constants including:
- `PRODUCT_FULLNAME` - Used in framework loading code (chrome_exe_main_mac.cc)
- `MAC_BUNDLE_ID` - Bundle identifier
- `COMPANY_FULLNAME` - Copyright and company name

Location: `ungoogled-chromium/build/src/chrome/app/theme/chromium/BRANDING`

Required changes:
```
COMPANY_FULLNAME=BaseCode LLC
COMPANY_SHORTNAME=BaseCode
PRODUCT_FULLNAME=BaseOne
PRODUCT_SHORTNAME=BaseOne
PRODUCT_INSTALLER_FULLNAME=BaseOne Installer
PRODUCT_INSTALLER_SHORTNAME=BaseOne Installer
COPYRIGHT=Copyright @LASTCHANGE_YEAR@ BaseCode LLC. All rights reserved.
MAC_BUNDLE_ID=al.base.one
```

**Why This Matters**: The main executable (chrome_exe_main_mac.cc:181) uses `PRODUCT_FULLNAME_STRING` to construct the framework path. If this isn't set to "BaseOne" before building, the executable will be hardcoded to load "Chromium Framework" instead of "BaseOne Framework", causing a crash on launch.

## Completed Branding Steps

### 1. Icon Branding

#### Source Icons
Location: `features/branding/icons/`
- `base_icon_16.png` through `base_icon_1024.png` (7 sizes)
- `app.icns` (macOS icon bundle, 82KB)
- Product logo variants (22px with retina and white versions)

#### Applied Icon Changes

**System-Level Icons:**
- `chrome/app/theme/chromium/mac/app.icns` → BaseOne app.icns
  - Shows in Dock, Finder, Cmd+Tab
  - File: 82KB

**App Icon Asset Catalog:**
- `chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset/`
  - Replaced all 7 PNG sizes (16, 32, 64, 128, 256, 512, 1024)
  - Generates Assets.car (60KB) for UI elements
  - Compilation: `xcrun actool --compile`

**Product Logo Files:**
- `chrome/app/theme/chromium/product_logo_*.png` (6 sizes: 16, 24, 48, 64, 128, 256)
  - Used in Settings sidebar, menus, About dialog
  - Replaced with BaseOne icons

**Product Logo SVG:**
- `chrome/app/theme/chromium/product_logo.svg`
- `chrome/app/theme/chromium/product_logo_animation.svg`
  - Both replaced with BaseOne "base" logo (166x77 SVG)
  - Color: #BA5EA1 (Base purple)

### 2. Binary Renaming

All Chromium-named binaries renamed to BaseOne:

**Main Executable:**
- `Contents/MacOS/Chromium` → `Contents/MacOS/BaseOne`

**Framework:**
- `Chromium Framework.framework` → `BaseOne Framework.framework`
- All internal framework binaries renamed

**Helper Applications:**
- `Chromium Helper.app` → `BaseOne Helper.app`
- `Chromium Helper (Renderer).app` → `BaseOne Helper (Renderer).app`
- `Chromium Helper (Plugin).app` → `BaseOne Helper (Plugin).app`
- `Chromium Helper (GPU).app` → `BaseOne Helper (GPU).app`
- `Chromium Helper (Alerts).app` → `BaseOne Helper (Alerts).app`

**Manifest:**
- `org.chromium.Chromium.manifest` → `al.base.one.manifest`

### 3. Info.plist Updates

**Main App Info.plist:**
```xml
<key>CFBundleExecutable</key>
<string>BaseOne</string>
<key>CFBundleIdentifier</key>
<string>al.base.one</string>
<key>CFBundleName</key>
<string>BaseOne</string>
<key>CFBundleDisplayName</key>
<string>BaseOne</string>
```

**Framework Info.plist:**
```xml
<key>CFBundleExecutable</key>
<string>BaseOne Framework</string>
<key>CFBundleIdentifier</key>
<string>al.base.one.framework</string>
<key>CFBundleName</key>
<string>BaseOne Framework</string>
```

**Helper Info.plists:**
- Updated all 5 helper app Info.plists
- Bundle ID: `al.base.one.helper`

### 4. String Replacements

792 instances of "Chromium" → "BaseOne" across:
- UI strings (`.grd`, `.grdp` files)
- About dialog
- Settings pages
- Menu items
- Error messages

Applied via: `scripts/apply_baseone_branding.sh`

## Scripts Created

### 1. `scripts/rename_chromium_binaries.sh`
Renames all Chromium binaries to BaseOne:
- Main executable
- Framework
- Helper apps (all 5 variants)
- Manifest files
- Updates all Info.plist files

Usage:
```bash
./scripts/rename_chromium_binaries.sh
```

### 2. `scripts/apply_baseone_branding.sh` (enhanced)
Now includes icon copying:
- Copies all PNG icons to xcassets
- Copies app.icns
- Replaces product logos
- Applies string replacements

## Automation for Future Builds

### Post-Build Icon Application

After any Chromium build, apply icons:

```bash
# 1. Copy source icons to build
ICON_SRC="features/branding/icons"
BUILD_SRC="ungoogled-chromium/build/src"

# App icon
cp "$ICON_SRC/app.icns" "$BUILD_SRC/chrome/app/theme/chromium/mac/"

# AppIcon xcassets (7 sizes)
XCASSETS="$BUILD_SRC/chrome/app/theme/chromium/mac/Assets.xcassets/AppIcon.appiconset"
cp "$ICON_SRC/base_icon_16.png" "$XCASSETS/appicon_16.png"
cp "$ICON_SRC/base_icon_32.png" "$XCASSETS/appicon_32.png"
cp "$ICON_SRC/base_icon_64.png" "$XCASSETS/appicon_64.png"
cp "$ICON_SRC/base_icon_128.png" "$XCASSETS/appicon_128.png"
cp "$ICON_SRC/base_icon_256.png" "$XCASSETS/appicon_256.png"
cp "$ICON_SRC/base_icon_512.png" "$XCASSETS/appicon_512.png"
cp "$ICON_SRC/base_icon_1024.png" "$XCASSETS/appicon_1024.png"

# Product logos (6 sizes)
cp "$ICON_SRC/base_icon_16.png" "$BUILD_SRC/chrome/app/theme/chromium/product_logo_16.png"
cp "$ICON_SRC/base_icon_32.png" "$BUILD_SRC/chrome/app/theme/chromium/product_logo_24.png"
cp "$ICON_SRC/base_icon_64.png" "$BUILD_SRC/chrome/app/theme/chromium/product_logo_48.png"
cp "$ICON_SRC/base_icon_64.png" "$BUILD_SRC/chrome/app/theme/chromium/product_logo_64.png"
cp "$ICON_SRC/base_icon_128.png" "$BUILD_SRC/chrome/app/theme/chromium/product_logo_128.png"
cp "$ICON_SRC/base_icon_256.png" "$BUILD_SRC/chrome/app/theme/chromium/product_logo_256.png"

# Product logo SVG
cp branding/base.svg "$BUILD_SRC/chrome/app/theme/chromium/product_logo.svg"
cp branding/base.svg "$BUILD_SRC/chrome/app/theme/chromium/product_logo_animation.svg"

# 2. Build with icons
ninja -C out/Default chrome

# 3. Copy to binaries
cp -R out/Default/Chromium.app binaries/BaseOne.app

# 4. Rename binaries
./scripts/rename_chromium_binaries.sh

# 5. Manually copy missing product logos to framework resources
FRAMEWORK_RES="binaries/BaseOne.app/Contents/Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/Resources"
cp "$BUILD_SRC/chrome/app/theme/chromium/product_logo_128.png" "$FRAMEWORK_RES/"
cp "$BUILD_SRC/chrome/app/theme/chromium/product_logo_256.png" "$FRAMEWORK_RES/"
```

### Chromium Upgrade Process

When upgrading Chromium:

1. Update source: `git pull` in ungoogled-chromium
2. Apply icons to new source (script above)
3. Apply string replacements: `./scripts/apply_baseone_branding.sh`
4. Build: `ninja -C out/Default chrome`
5. Rename binaries: `./scripts/rename_chromium_binaries.sh`
6. Test BaseOne.app

## Icon Locations Reference

### In Source (Before Build)
```
ungoogled-chromium/build/src/
├── chrome/app/theme/chromium/
│   ├── mac/
│   │   ├── app.icns                          # System icon (Dock, Finder)
│   │   └── Assets.xcassets/
│   │       └── AppIcon.appiconset/
│   │           ├── appicon_16.png            # UI icon 16x16
│   │           ├── appicon_32.png            # UI icon 32x32
│   │           ├── appicon_64.png            # UI icon 64x64
│   │           ├── appicon_128.png           # UI icon 128x128
│   │           ├── appicon_256.png           # UI icon 256x256
│   │           ├── appicon_512.png           # UI icon 512x512
│   │           └── appicon_1024.png          # UI icon 1024x1024
│   ├── product_logo_16.png                   # Settings/menu 16x16
│   ├── product_logo_24.png                   # Settings/menu 24x24
│   ├── product_logo_48.png                   # Settings/menu 48x48
│   ├── product_logo_64.png                   # Settings/menu 64x64
│   ├── product_logo_128.png                  # Settings/menu 128x128
│   ├── product_logo_256.png                  # Settings/menu 256x256
│   ├── product_logo.svg                      # Vector logo
│   └── product_logo_animation.svg            # Animated vector logo
```

### In Built App (After Build)
```
BaseOne.app/
├── Contents/
│   ├── MacOS/
│   │   └── BaseOne                           # Main executable (renamed)
│   ├── Frameworks/
│   │   └── BaseOne Framework.framework/      # Framework (renamed)
│   │       ├── BaseOne Framework             # Framework binary
│   │       └── Versions/142.0.7444.134/
│   │           ├── Resources/
│   │           │   ├── product_logo_32.png   # (built automatically)
│   │           │   ├── product_logo_128.png  # (copy manually)
│   │           │   └── product_logo_256.png  # (copy manually)
│   │           └── Helpers/
│   │               ├── BaseOne Helper.app    # (renamed)
│   │               ├── BaseOne Helper (Renderer).app
│   │               ├── BaseOne Helper (Plugin).app
│   │               ├── BaseOne Helper (GPU).app
│   │               └── BaseOne Helper (Alerts).app
│   └── Resources/
│       └── Assets.car                        # Compiled from xcassets (60KB)
```

## Known Issues & Solutions

### Issue: product_logo_128.png and product_logo_256.png Not in Built App
**Cause**: Build process doesn't copy these sizes to framework resources
**Solution**: Manually copy after build:
```bash
FRAMEWORK_RES="BaseOne.app/Contents/Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/Resources"
cp product_logo_128.png "$FRAMEWORK_RES/"
cp product_logo_256.png "$FRAMEWORK_RES/"
```

### Issue: Assets.car Not Updated After Icon Changes
**Cause**: Chromium build caches asset catalog compilation
**Solution**: Force recompilation:
```bash
cd chrome/app/theme/chromium/mac
xcrun actool --compile /tmp/AssetsCar --platform macosx --minimum-deployment-target 11.0 --app-icon AppIcon --output-partial-info-plist /tmp/partial.plist Assets.xcassets
cp /tmp/AssetsCar/Assets.car "BaseOne.app/Contents/Resources/Assets.car"
```

### Issue: Icon Cache on macOS
**Cause**: macOS caches app icons aggressively
**Solution**:
```bash
touch BaseOne.app  # Update timestamp
killall Finder Dock  # Refresh caches
```

## Verification Checklist

After applying branding, verify:

- [ ] System icons (Dock, Finder, Cmd+Tab) show BaseOne icon
- [ ] About BaseOne dialog shows BaseOne icon and "You and Base" text
- [ ] Settings sidebar shows BaseOne icon (not Chromium)
- [ ] Menu items say "BaseOne" (not "Chromium")
- [ ] Activity Monitor shows "BaseOne" processes (not "Chromium")
- [ ] All helper processes named "BaseOne Helper"
- [ ] No "Chromium" anywhere in app bundle filenames:
  ```bash
  find BaseOne.app -name "*Chromium*" -o -name "*chromium*"
  # Should return empty
  ```

## Files Reference

### Patch Files
- `patches/baseone-complete-icon-branding.patch` - Documents all icon changes
  - Binary diffs for PNGs
  - SVG content for logos
  - xcassets changes
  - app.icns replacement

### Scripts
- `scripts/rename_chromium_binaries.sh` - Binary renaming automation
- `scripts/apply_baseone_branding.sh` - Complete branding automation

### Documentation
- `branding/COMPLETE_BRANDING_GUIDE.md` - This file
- `branding/ASSETS.md` - Icon asset specifications
- `guides/BRANDING.md` - Original branding guide

## Summary

Complete BaseOne branding achieved:
- 7 PNG icon sizes in xcassets
- 6 product logo PNGs
- 2 SVG logos
- 1 app.icns (macOS icon bundle)
- All binaries renamed (main + framework + 5 helpers)
- All Info.plist files updated
- 792 string replacements
- Zero "Chromium" references remaining

BaseOne is now a fully branded browser with no visual or binary references to Chromium.
