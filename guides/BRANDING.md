# Base Dev Branding Guide

Complete guide for managing Base Dev browser branding, including assets, strings, and build integration.

## Overview

Base Dev uses a two-phase branding approach:
1. **String Replacement**: 352 Chromium strings replaced with Base Dev via patch system
2. **Asset Replacement**: Icons and logos generated from SVG sources and integrated into build

This guide covers both systems and how to maintain them.

---

## Quick Start

### Apply Existing Branding

```bash
cd /Volumes/External/BaseChrome/base-core

# Build with branding (automatically applies patches)
./scripts/6_build_incremental.sh

# Or apply strings and build in one step
./scripts/7_apply_strings_and_build.sh
```

The string patch is automatically applied during the build process. Icons are already in place from previous builds.

### Regenerate Icons

```bash
# Generate all icons from SVG sources
./features/branding/scripts/generate_icons.sh

# Apply icons to build
./features/branding/apply.sh
```

---

## Architecture

### Branding System Components

```
Base Dev Branding System
│
├── Source Assets (version controlled)
│   ├── /branding/base.svg (full logo)
│   ├── /branding/base_browser.svg (icon only)
│   └── /branding/base_*.svg (variant logos)
│
├── String Replacements (patch-based)
│   └── /patches/ungoogled-chromium/base-branding-strings.patch
│       └── Replaces 352 instances of "Chromium" → "Base Dev"
│
├── Generated Assets (from sources)
│   ├── /branding/generated_icons/
│   │   ├── app.icns (macOS icon bundle)
│   │   ├── base_icon_*.png (all sizes)
│   │   └── product_logo_*.png (UI logos)
│   │
│   └── /features/branding/icons/ (duplicate for feature management)
│
└── Build Integration
    └── ungoogled-chromium/build/src/
        ├── chrome/app/theme/chromium/ (icons)
        └── chrome/app/*.grd (strings - patched)
```

### Workflow

1. **Design Phase**: Create/update SVG source files
2. **Generation Phase**: Run `generate_icons.sh` to create all sizes
3. **Integration Phase**: Icons copied during build, strings patched automatically
4. **Build Phase**: Browser built with full Base Dev branding

---

## String Replacement System

### How It Works

The string replacement system uses a unified diff patch that modifies Chromium's `.grd` and `.grdp` resource files during the build process.

**Patch File**: `/Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/base-branding-strings.patch`

**Application**: Automatically applied when building via `./scripts/6_build_incremental.sh` or `./scripts/7_apply_strings_and_build.sh`

### Files Modified by Patch

```
chrome/app/
├── chromium_strings.grd                      # Main product strings
├── settings_chromium_strings.grdp            # Settings UI
├── generated_resources.grd                   # Generated resources
├── google_chrome_strings.grd                 # Chrome-specific strings
├── password_manager_ui_strings.grdp          # Password manager
├── settings_google_chrome_strings.grdp       # Settings (Google)
├── settings_strings.grdp                     # General settings
└── shared_settings_strings.grdp              # Shared settings
```

### String Categories

**Product Names**:
```xml
<!-- Before -->
<message name="IDS_PRODUCT_NAME">Chromium</message>

<!-- After -->
<message name="IDS_PRODUCT_NAME">Base Dev</message>
```

**Company/Copyright**:
```xml
<!-- Before -->
<message name="IDS_ABOUT_PRODUCT_COPYRIGHT">
  Copyright © 2025 The Chromium Authors
</message>

<!-- After -->
<message name="IDS_ABOUT_PRODUCT_COPYRIGHT">
  Copyright © 2025 BaseDev Team. Based on Chromium, Copyright The Chromium Authors.
</message>
```

**UI Strings**:
- Window titles: "Page - Chromium" → "Page - Base Dev"
- Menus: "About Chromium" → "About Base Dev"
- Dialogs: "Chromium is unresponsive" → "Base Dev is unresponsive"
- Settings: "Make Chromium default" → "Make Base Dev default"
- And 300+ more instances

### Total Replacements

- **352 instances** of "Chromium" → "Base Dev"
- **100% coverage** of user-facing strings
- **0 remaining** Chromium references in UI

### Updating String Replacements

If you need to add new string replacements:

1. Find the Chromium string in source:
   ```bash
   cd ungoogled-chromium/build/src
   grep -r "Chromium" chrome/app/*.grd chrome/app/*.grdp
   ```

2. Modify the patch file:
   ```bash
   cd /Volumes/External/BaseChrome/base-core
   nano patches/ungoogled-chromium/base-branding-strings.patch
   ```

3. Add new replacement in unified diff format:
   ```diff
   @@ -123,7 +123,7 @@
    <messages fallback_to_english="true">
      <message name="IDS_NEW_STRING" desc="Description">
   -    Chromium
   +    Base Dev
      </message>
    </messages>
   ```

4. Rebuild to apply:
   ```bash
   ./scripts/6_build_incremental.sh
   ```

### Alternative: Regenerate Patch from Source

If you've made extensive changes directly in source files:

```bash
cd ungoogled-chromium/build/src

# Stage your changes
git add chrome/app/*.grd chrome/app/*.grdp

# Create patch
git diff --cached > /Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/base-branding-strings.patch

# Unstage
git reset
```

---

## Icon & Logo System

### Source Assets

All branding starts with these SVG source files:

**Location**: `/Volumes/External/BaseChrome/base-core/branding/`

| File | Purpose | Usage |
|------|---------|-------|
| `base.svg` | Full logo with text | Product logos in UI |
| `base_browser.svg` | Icon only | App icon generation |
| `base_ai.svg` | AI variant | Future use |
| `base_code.svg` | Code variant | Future use |
| `base_code_alt.svg` | Code variant (alt) | Future use |

**Design Principles**:
- Simple and clean (works at 16x16px)
- Distinctive silhouette
- Scalable (vector format)
- Professional aesthetic
- Uses brand colors (blue/purple gradient)

### Icon Generation

**Script**: `/Volumes/External/BaseChrome/base-core/features/branding/scripts/generate_icons.sh`

**What it generates**:
1. **macOS App Icon** (`app.icns`):
   - 16x16, 32x32, 128x128, 256x256, 512x512, 1024x1024
   - @2x variants for each size (except 1024)
   - All sizes bundled into single .icns file

2. **PNG Icons** (all sizes):
   - base_icon_16.png → base_icon_1024.png
   - Used for favicons, bookmarks, UI elements

3. **Product Logos** (UI usage):
   - product_logo_name_22.png (normal DPI)
   - product_logo_name_22@2x.png (Retina)
   - White variants for dark backgrounds

**Requirements**:
```bash
# Install dependencies (macOS)
brew install librsvg  # Provides rsvg-convert
# iconutil is built into macOS
```

**Run generation**:
```bash
cd /Volumes/External/BaseChrome/base-core

# Generate all icons
./features/branding/scripts/generate_icons.sh

# Output: features/branding/icons/
```

### Icon Sizes Explained

**macOS .icns Requirements**:
```
16x16      → Smallest UI elements, favicons
16x16@2x   → Retina version (32x32)
32x32      → Standard small icon
32x32@2x   → Retina version (64x64)
128x128    → Standard medium icon
128x128@2x → Retina version (256x256)
256x256    → Standard large icon
256x256@2x → Retina version (512x512)
512x512    → Extra large icon
512x512@2x → Retina version (1024x1024)
```

**Usage Contexts**:
- **Dock**: Uses 128x128@2x or larger
- **Finder**: Uses 512x512 for large icons
- **App Switcher** (Cmd+Tab): Uses 256x256
- **Title Bar**: Uses 16x16 or 32x32
- **Favicons**: Uses 16x16, 32x32

---

## Build Integration

### How Icons Get Into Build

1. **Generation**: Run `generate_icons.sh` to create all icon files

2. **Copy to Build**: Icons are copied to Chromium source tree:
   ```bash
   # Via apply script
   ./features/branding/apply.sh

   # Or manually
   cp features/branding/icons/* \
      ungoogled-chromium/build/src/chrome/app/theme/chromium/
   ```

3. **Build**: Browser build process packages icons into .app bundle:
   ```
   out/Default/Base Dev.app/Contents/Resources/
   ├── app.icns
   └── product_logo_*.png
   ```

### How Strings Get Into Build

Strings are automatically patched during the build process:

1. **Patch Applied**: Build system applies all patches from `/patches/series`
2. **Resources Compiled**: `.grd` files compiled into binary resources
3. **Localization**: Strings compiled for all supported locales
4. **Packaging**: Resources bundled into .app

**No manual intervention needed** - just build and strings are replaced.

---

## Customization

### Changing Product Name

If you want to rename from "Base Dev" to something else:

1. **Update String Patch**:
   ```bash
   nano patches/ungoogled-chromium/base-branding-strings.patch

   # Replace all instances of "Base Dev" with your new name
   # Use find-replace in your editor
   ```

2. **Update Build Configuration** (if needed):
   ```bash
   nano ungoogled-chromium/build/src/chrome/app/theme/chromium/BRANDING
   # Update product name constants
   ```

3. **Update Info.plist Branding**:
   ```bash
   # Edit during build or via instant branding script
   nano features/branding/apply_instant.sh
   ```

4. **Rebuild**:
   ```bash
   ./scripts/6_build_incremental.sh
   ```

### Changing Icons

To update the icon design:

1. **Edit SVG Source**:
   ```bash
   # Use your preferred SVG editor (Figma, Sketch, Illustrator, Inkscape)
   open branding/base_browser.svg
   # Make your changes
   ```

2. **Regenerate All Sizes**:
   ```bash
   ./features/branding/scripts/generate_icons.sh
   ```

3. **Apply to Build**:
   ```bash
   ./features/branding/apply.sh
   ```

4. **Rebuild**:
   ```bash
   ./scripts/6_build_incremental.sh
   ```

### Adding New Logo Variants

To add a new logo variant (e.g., for dark mode):

1. **Create SVG**:
   ```bash
   # Create base_dark.svg or base_white.svg
   cp branding/base.svg branding/base_dark.svg
   # Edit colors for dark theme
   ```

2. **Update Generation Script**:
   ```bash
   nano features/branding/scripts/generate_icons.sh

   # Add generation for new variant
   rsvg-convert -h 22 "$BRANDING_SRC/base_dark.svg" > \
       "$ICONS_OUTPUT/product_logo_dark_22.png"
   ```

3. **Regenerate**:
   ```bash
   ./features/branding/scripts/generate_icons.sh
   ```

---

## Testing

### Visual Testing Checklist

After applying branding changes, test in these contexts:

**macOS Icon Contexts**:
- [ ] Dock icon (normal and large sizes)
- [ ] Finder icon
- [ ] App Switcher (Cmd+Tab)
- [ ] Title bar icon
- [ ] Spotlight results
- [ ] Desktop icon
- [ ] Quick Look preview

**UI String Contexts**:
- [ ] Window title bar
- [ ] About page (chrome://about)
- [ ] Settings page
- [ ] New Tab Page
- [ ] Context menus
- [ ] Dialog boxes
- [ ] Error pages
- [ ] Downloads page
- [ ] History page
- [ ] Extensions page

**Display Densities**:
- [ ] Standard DPI (1x)
- [ ] Retina DPI (2x)
- [ ] Different display resolutions

**Themes**:
- [ ] Light mode
- [ ] Dark mode
- [ ] System theme (auto-switch)

### Automated Testing

```bash
# Check for remaining "Chromium" strings
cd ungoogled-chromium/build/src
grep -r "Chromium" out/Default/Base\ Dev.app/Contents/Resources/*.pak

# Verify icon files exist
ls -lh out/Default/Base\ Dev.app/Contents/Resources/app.icns
ls -lh out/Default/Base\ Dev.app/Contents/Resources/product_logo*.png

# Check Info.plist
/usr/libexec/PlistBuddy -c "Print CFBundleName" \
    out/Default/Base\ Dev.app/Contents/Info.plist
# Should output: Base Dev
```

---

## Maintenance

### When to Update Branding

**Update string patch when**:
- Upgrading to new Chromium version (new strings may be added)
- Adding new features that introduce UI strings
- Discovering missed "Chromium" references
- Changing product name

**Regenerate icons when**:
- Updating logo design
- Changing brand colors
- Adding new icon sizes
- Creating seasonal variants

### Chromium Version Updates

When updating to a new Chromium version:

1. **Check for new strings**:
   ```bash
   cd ungoogled-chromium/build/src
   git log --oneline --since="2025-01-01" -- chrome/app/*.grd chrome/app/*.grdp
   ```

2. **Search for new Chromium references**:
   ```bash
   grep -r "Chromium" chrome/app/*.grd chrome/app/*.grdp | \
       grep -v "<!-- Chromium -->"  # Exclude comments
   ```

3. **Update patch** with new replacements

4. **Test build** to ensure no regressions

### Asset Optimization

For production builds, optimize generated assets:

```bash
# Optimize PNG files
cd features/branding/icons
optipng -o7 *.png

# Or use pngcrush
pngcrush -brute base_icon_*.png optimized/

# Re-create .icns from optimized PNGs
# (Update generate_icons.sh to use optimized PNGs)
```

---

## Directory Structure

```
/Volumes/External/BaseChrome/base-core/
│
├── branding/                          # Source assets (version controlled)
│   ├── base.svg                       # Full logo master
│   ├── base_browser.svg               # Icon master
│   ├── base_*.svg                     # Variants
│   ├── generated_icons/               # Generated (can be in .gitignore)
│   │   ├── app.icns
│   │   ├── base_icon_*.png
│   │   └── product_logo_*.png
│   └── ASSETS.md                      # This inventory
│
├── features/branding/                 # Branding feature module
│   ├── icons/                         # Generated icons (duplicate)
│   ├── patches/                       # Legacy patches
│   ├── scripts/
│   │   ├── generate_icons.sh          # Main generation script
│   │   ├── generate_icon.sh           # Single icon helper
│   │   ├── find_chromium_strings.sh   # String auditing
│   │   └── replace_strings.sh         # Legacy string replacement
│   ├── apply.sh                       # Apply icons to build
│   ├── apply_instant.sh               # Quick branding apply
│   ├── rollback.sh                    # Revert to Chromium branding
│   ├── config.sh                      # Configuration
│   ├── README.md                      # Feature documentation
│   ├── STRING_REPLACEMENTS.md         # Replacement log
│   └── STRING_REPLACEMENT_COMPLETE.md # Completion status
│
├── patches/ungoogled-chromium/
│   └── base-branding-strings.patch    # String replacement patch
│
├── guides/
│   └── BRANDING.md                    # This guide
│
└── progress/current/
    └── complete-branding-system.md    # Feature plan
```

---

## Common Tasks

### Create a Complete Branding Update

Full workflow for updating branding:

```bash
cd /Volumes/External/BaseChrome/base-core

# 1. Update SVG sources
open branding/base.svg
open branding/base_browser.svg
# Make your design changes...

# 2. Generate all icons
./features/branding/scripts/generate_icons.sh

# 3. Review generated icons
open features/branding/icons/

# 4. Apply icons to build
./features/branding/apply.sh

# 5. Update strings if needed
nano patches/ungoogled-chromium/base-branding-strings.patch

# 6. Build with new branding
./scripts/6_build_incremental.sh

# 7. Test the built browser
open "ungoogled-chromium/build/src/out/Default/Base Dev.app"
```

### Audit for Missed Chromium References

```bash
cd ungoogled-chromium/build/src

# Search all resource files
grep -r "Chromium" chrome/app/*.grd chrome/app/*.grdp

# Search compiled resources (after build)
strings out/Default/Base\ Dev.app/Contents/Resources/*.pak | grep Chromium

# Search UI code for hardcoded strings
grep -r "\"Chromium\"" chrome/browser/ui/
```

### Create a New Logo Variant

```bash
# 1. Copy existing logo as template
cp branding/base.svg branding/base_new_variant.svg

# 2. Edit the new variant
open branding/base_new_variant.svg
# Make your changes...

# 3. Add generation to script
echo 'rsvg-convert -h 22 "$BRANDING_SRC/base_new_variant.svg" > "$ICONS_OUTPUT/variant_22.png"' >> \
    features/branding/scripts/generate_icons.sh

# 4. Generate
./features/branding/scripts/generate_icons.sh
```

### Rollback to Chromium Branding

```bash
cd /Volumes/External/BaseChrome/base-core

# Remove string patch from series
sed -i '' '/base-branding-strings.patch/d' patches/series

# Restore Chromium icons (if needed)
./features/branding/rollback.sh

# Rebuild without branding
./scripts/6_build_incremental.sh
```

---

## Troubleshooting

### Icons Not Showing After Build

**Problem**: Built browser still shows Chromium icons

**Solution**:
```bash
# Ensure icons were copied to source
ls -la ungoogled-chromium/build/src/chrome/app/theme/chromium/*.icns

# If missing, apply icons
./features/branding/apply.sh

# Clean build and rebuild
cd ungoogled-chromium/build/src
ninja -C out/Default -t clean
cd /Volumes/External/BaseChrome/base-core
./scripts/6_build_incremental.sh
```

### Strings Still Show "Chromium"

**Problem**: UI still shows "Chromium" in some places

**Solutions**:
```bash
# 1. Verify patch is in series
cat patches/series | grep base-branding-strings

# 2. Check if patch applied successfully
cd ungoogled-chromium/build/src
git status  # Should show modified .grd files

# 3. If not applied, rebuild
cd /Volumes/External/BaseChrome/base-core
./scripts/6_build_incremental.sh
```

### Icon Generation Fails

**Problem**: `generate_icons.sh` fails with errors

**Common causes**:
```bash
# Missing rsvg-convert
brew install librsvg

# Missing iconutil (should be in macOS)
which iconutil  # Should exist

# SVG source file not found
ls -la branding/base_browser.svg
ls -la branding/base.svg

# Permissions issue
chmod +x features/branding/scripts/generate_icons.sh
```

### Wrong Icon Sizes in .icns

**Problem**: macOS complains about icon format

**Solution**:
```bash
# Verify .icns is valid
iconutil -c iconset features/branding/icons/app.icns -o /tmp/test.iconset
ls /tmp/test.iconset  # Should show all required sizes

# If invalid, regenerate
rm features/branding/icons/app.icns
./features/branding/scripts/generate_icons.sh
```

---

## Best Practices

### Source Control

**Always version control**:
- Source SVG files (`branding/*.svg`)
- String replacement patch
- Generation scripts
- This documentation

**Can ignore** (regenerable):
- `branding/generated_icons/`
- `features/branding/icons/`

**Add to .gitignore**:
```gitignore
# Generated branding assets (can be regenerated from sources)
branding/generated_icons/
features/branding/icons/
```

### Design Workflow

1. **Master sources**: Always edit SVG sources, never edit generated PNGs
2. **Version control**: Commit SVG changes with meaningful messages
3. **Regenerate**: Always regenerate all sizes after SVG changes
4. **Test**: Test icons at all sizes before committing
5. **Document**: Update ASSETS.md when adding new variants

### String Management

1. **Centralized**: Keep all string replacements in one patch file
2. **Documented**: Comment complex replacements in the patch
3. **Tested**: Test UI in multiple languages if possible
4. **Audited**: Regularly audit for missed references

### Build Integration

1. **Automated**: Use build scripts, don't manually copy files
2. **Verified**: Always test after branding changes
3. **Incremental**: Use incremental builds for faster iteration
4. **Clean**: Occasionally do clean builds to verify

---

## Related Resources

### Documentation

- **Asset Inventory**: `branding/ASSETS.md` - Complete list of all assets
- **Feature Plan**: `progress/current/complete-branding-system.md` - Implementation plan
- **String Documentation**: `features/branding/STRING_REPLACEMENT_COMPLETE.md` - Replacement details
- **Feature README**: `features/branding/README.md` - Quick reference

### Tools

- **Icon Generation**: `features/branding/scripts/generate_icons.sh`
- **Icon Apply**: `features/branding/apply.sh`
- **Instant Branding**: `features/branding/apply_instant.sh`
- **Rollback**: `features/branding/rollback.sh`

### External References

- [Chromium Branding Guidelines](https://www.chromium.org/developers/branding-guidelines/)
- [macOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Web App Manifest Icons](https://web.dev/add-manifest/)
- [rsvg-convert Documentation](https://manpages.debian.org/testing/librsvg2-bin/rsvg-convert.1.en.html)
- [iconutil Documentation](https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Optimizing/Optimizing.html)

---

## Changelog

### 2025-11-08
- Initial branding guide created
- Documented complete branding system
- Added workflow examples
- Created troubleshooting section

---

**Maintained by**: BaseDev Team
**Last Updated**: 2025-11-08
