# BaseOne Branding Assets Inventory

Complete inventory of all branding assets for BaseOne browser.

## Quick Reference

- **Source Files**: `/Volumes/External/BaseChrome/base-core/branding/`
- **Generated Icons**: `/Volumes/External/BaseChrome/base-core/branding/generated_icons/`
- **Feature Icons**: `/Volumes/External/BaseChrome/base-core/features/branding/icons/`
- **String Patch**: `/Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/base-branding-strings.patch`
- **Generation Script**: `/Volumes/External/BaseChrome/base-core/features/branding/scripts/generate_icons.sh`

---

## Source Assets

### Logo Variants

Located in: `/Volumes/External/BaseChrome/base-core/branding/`

| File | Purpose | Format | Status |
|------|---------|--------|--------|
| `base.svg` | Full Base logo with text | SVG | Master source |
| `base_browser.svg` | Icon only (no text) | SVG | Master source |
| `base_ai.svg` | AI variant logo | SVG | Available |
| `base_code.svg` | Code variant logo | SVG | Available |
| `base_code_alt.svg` | Code variant (alt) | SVG | Available |

**Usage**:
- `base.svg` - Used for product logos in UI (menus, toolbars, About page)
- `base_browser.svg` - Used for app icon generation (.icns, favicons)
- Other variants - Reserved for future product differentiation

---

## Generated Assets

### macOS Application Icon

**File**: `app.icns`
**Location**: `/Volumes/External/BaseChrome/base-core/branding/generated_icons/app.icns`
**Size**: ~263 KB
**Contains**: All required icon sizes for macOS (16x16 to 1024x1024, with @2x variants)

**Sizes Included**:
- icon_16x16.png
- icon_16x16@2x.png (32x32)
- icon_32x32.png
- icon_32x32@2x.png (64x64)
- icon_128x128.png
- icon_128x128@2x.png (256x256)
- icon_256x256.png
- icon_256x256@2x.png (512x512)
- icon_512x512.png
- icon_512x512@2x.png (1024x1024)

**Usage Contexts**:
- Dock icon
- Finder icon
- App Switcher (Cmd+Tab)
- Title bar icon
- Desktop icon
- Quick Look icon

### App Icon PNGs

Located in: `/Volumes/External/BaseChrome/base-core/branding/generated_icons/`

| File | Size | Purpose | Format |
|------|------|---------|--------|
| `base_icon_16.png` | 16x16 | Small UI elements | PNG-24 |
| `base_icon_24.png` | 24x24 | Small UI elements | PNG-24 |
| `base_icon_32.png` | 32x32 | Standard icon | PNG-24 |
| `base_icon_48.png` | 48x48 | Medium icon | PNG-24 |
| `base_icon_64.png` | 64x64 | Medium icon @2x | PNG-24 |
| `base_icon_128.png` | 128x128 | Large icon | PNG-24 |
| `base_icon_256.png` | 256x256 | Large icon @2x | PNG-24 |
| `base_icon_512.png` | 512x512 | Extra large icon | PNG-24 |
| `base_icon_1024.png` | 1024x1024 | Extra large @2x | PNG-24 |

### Product Logos

Located in: `/Volumes/External/BaseChrome/base-core/branding/generated_icons/`

| File | Size | Purpose | Format |
|------|------|---------|--------|
| `product_logo_name_22.png` | ~width x 22px | UI menus/toolbars | PNG-24 |
| `product_logo_name_22@2x.png` | ~width x 44px | UI menus @2x | PNG-24 |
| `product_logo_name_22_white.png` | ~width x 22px | Dark backgrounds | PNG-24 |
| `product_logo_name_22_white@2x.png` | ~width x 44px | Dark backgrounds @2x | PNG-24 |

**Usage Contexts**:
- About page
- Settings header
- Menu items
- Toolbar branding
- Splash screens
- Error pages

---

## String Replacements

**Patch File**: `/Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/base-branding-strings.patch`
**Total Replacements**: 352 instances
**Status**: Complete

### Files Modified by Patch

1. `chrome/app/chromium_strings.grd` - Main product strings
2. `chrome/app/settings_chromium_strings.grdp` - Settings UI strings
3. `chrome/app/generated_resources.grd` - Generated resource strings
4. `chrome/app/google_chrome_strings.grd` - Chrome-specific strings
5. `chrome/app/password_manager_ui_strings.grdp` - Password manager
6. `chrome/app/settings_google_chrome_strings.grdp` - Settings (Google variant)
7. `chrome/app/settings_strings.grdp` - General settings strings
8. `chrome/app/shared_settings_strings.grdp` - Shared settings strings

### String Categories

**Product Names**:
- "Chromium" → "BaseOne"
- "Chromium Helper" → "BaseOne Helper"
- "Google Chrome" → "BaseOne" (where applicable)

**Company/Copyright**:
- "The Chromium Authors" → "BaseOne Team"
- "Copyright © 2025 BaseOne Team"
- "Based on Chromium, Copyright The Chromium Authors"

**URLs** (Placeholder - awaiting final domains):
- chromium.org → basedev.example
- Support links → TBD

**UI Strings**:
- Window titles
- Menu items
- Dialog messages
- Error messages
- Settings labels
- About page content

---

## Asset Locations in Build

### Build Integration

When the browser is built, assets are copied to:

```
ungoogled-chromium/build/src/out/Default/BaseOne.app/Contents/
├── Resources/
│   ├── app.icns                         # Main app icon
│   └── product_logo_*.png               # Product logos
└── Info.plist                            # Bundle identifier, display name
```

### Info.plist Branding

```xml
<key>CFBundleName</key>
<string>BaseOne</string>
<key>CFBundleDisplayName</key>
<string>BaseOne</string>
<key>CFBundleIdentifier</key>
<string>al.base.BaseOne</string>
<key>CFBundleIconFile</key>
<string>app.icns</string>
```

---

## Regeneration Instructions

### Generate All Icons from Source

```bash
cd /Volumes/External/BaseChrome/base-core

# Generate icons from SVG sources
./features/branding/scripts/generate_icons.sh

# Output: features/branding/icons/
# - app.icns
# - base_icon_*.png (all sizes)
# - product_logo_*.png (all variants)
```

**Requirements**:
- `rsvg-convert` (install: `brew install librsvg`)
- `iconutil` (macOS built-in)

### Apply Icons to Build

```bash
# Copy icons to build directory
./features/branding/apply.sh

# This copies icons to:
# ungoogled-chromium/build/src/chrome/app/theme/chromium/
```

### Rebuild with Branding

```bash
# Apply strings and icons, then build
./scripts/7_apply_strings_and_build.sh

# Or manually:
# 1. Apply string patch (automatically done in build)
# 2. Copy icons
# 3. Build
./scripts/6_build_incremental.sh
```

---

## File Sizes

### Source Files

| File | Size | Notes |
|------|------|-------|
| base.svg | ~8 KB | Vector, scalable |
| base_browser.svg | ~1 KB | Vector, scalable |
| base_ai.svg | ~1 KB | Vector, scalable |
| base_code.svg | ~1 KB | Vector, scalable |
| base_code_alt.svg | ~1 KB | Vector, scalable |

### Generated Files

| Asset Type | Total Size | Count |
|------------|------------|-------|
| app.icns | ~263 KB | 1 file |
| PNG icons (all sizes) | ~145 KB | 9 files |
| Product logos | ~22 KB | 4 files |
| **Total** | **~430 KB** | **14 files** |

**Build Impact**: ~1-2 MB (including all variants and locales)

---

## Asset Usage Map

### High Priority (Always Visible)

- **Dock/Finder**: `app.icns` → All users see this constantly
- **Window Title**: String replacement → "BaseOne" in title bar
- **About Page**: `product_logo_name_22.png` + string replacements
- **Settings**: Product logo + "BaseOne" strings

### Medium Priority (Frequently Visible)

- **Tab Favicon**: `base_icon_16.png` or `base_icon_32.png`
- **Bookmark Icons**: `base_icon_16.png`
- **Menu Items**: `product_logo_name_22.png`
- **Error Pages**: Product logo + "BaseOne" strings

### Low Priority (Rarely Visible)

- **Crash Reporter**: "BaseOne" strings
- **Print Dialog**: "BaseOne" in headers
- **Developer Tools**: "BaseOne" in titles
- **Internal Pages**: chrome:// pages with "BaseOne"

---

## Design Specifications

### Color Palette

**Current Design** (from existing SVGs):
- Primary: Blue/Purple gradient
- Accent: Various blues
- Background: Transparent
- Icon style: Modern, flat design

**Future Considerations**:
- Define exact hex colors for brand guidelines
- Create dark mode variants
- Ensure WCAG AA contrast compliance

### Icon Design Principles

From existing assets:
- **Simple and clean**: Works at 16x16px
- **Distinctive shape**: Recognizable silhouette
- **Scalable**: Looks good from 16px to 1024px
- **Professional**: Modern, minimalist aesthetic
- **Colorful**: Uses brand colors effectively

---

## Version Control

### Tracked in Git

**Source files** (always version controlled):
- `/branding/*.svg` - Master source files
- `/patches/ungoogled-chromium/base-branding-strings.patch` - String replacements
- `/features/branding/scripts/` - Generation scripts

**Generated files** (can be regenerated):
- `/branding/generated_icons/` - Generated from SVG sources
- `/features/branding/icons/` - Generated from SVG sources

**Recommendation**: Add `/branding/generated_icons/` and `/features/branding/icons/` to `.gitignore` since they can be regenerated from source SVGs.

---

## Related Documentation

- **Feature Plan**: `/Volumes/External/BaseChrome/base-core/progress/current/complete-branding-system.md`
- **String Replacements**: `/Volumes/External/BaseChrome/base-core/features/branding/STRING_REPLACEMENT_COMPLETE.md`
- **Branding README**: `/Volumes/External/BaseChrome/base-core/features/branding/README.md`
- **Developer Guide**: `/Volumes/External/BaseChrome/base-core/guides/BRANDING.md` (to be created)

---

## Future Asset Needs

### Not Yet Created

- **DMG Background**: Custom installer background image
- **DMG Window**: Styled installer window
- **Splash Screen**: App launch screen (if applicable)
- **Touch Icons**: For web manifest (180x180, 192x192, 512x512)
- **Favicon.ico**: Multi-size .ico file (16x16, 32x32, 48x48)
- **Logo Variants**:
  - Monochrome version
  - Dark mode optimized
  - Vertical layout
  - Compact/small version

### Planned Improvements

- Define official color palette with hex values
- Create brand guidelines document
- Generate web-optimized formats (WebP, optimized PNG)
- Create animated variants (for splash/loading)
- Design promotional materials

---

## Maintenance

### When to Regenerate

**Regenerate all icons when**:
- SVG source files are updated
- New sizes are needed
- Color palette changes
- Design refresh

**Update string patch when**:
- New Chromium strings added
- UI text changes upstream
- New product features need branding
- Chromium version updates

### Testing Checklist

After regenerating assets:
- [ ] Verify all icon sizes are present
- [ ] Check .icns file is valid
- [ ] Test icons at all display densities (1x, 2x)
- [ ] Verify colors match brand guidelines
- [ ] Check icons in Dock, Finder, App Switcher
- [ ] Test on both light and dark macOS themes

---

Generated: 2025-11-08
Last Updated: 2025-11-08
