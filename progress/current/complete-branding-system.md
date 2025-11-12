# Feature: Complete Branding System

## Metadata

- **Status**: In Progress
- **Started**: 2025-11-08
- **Completed**: TBD
- **Category**: Branding | UI
- **Priority**: High
- **Contributors**: Development Team

## Overview

Replace all Chromium branding with BaseOne branding throughout the browser. This includes string replacements (product names, company names, URLs), icons, logos, and all visual assets to create a cohesive BaseOne browser identity.

## Goals

- [ ] Replace all Chromium/Google strings with BaseOne equivalents
- [ ] Create custom icon set (app icons, favicons, splash screens)
- [ ] Generate product logos for all sizes and contexts
- [ ] Update About page and settings with BaseOne branding
- [ ] Create branded installer/DMG
- [ ] Ensure consistent branding across all platforms

## Technical Approach

### Architecture

Use a two-phase approach:
1. **String Replacement**: Comprehensive string patches applied via ungoogled-chromium patch system
2. **Asset Generation**: Automated icon/logo generation from master source files

### Components

- **String Patches**: Unified diff patches for .grd/.grdp resource files
- **Icon Generator**: Script to generate all required icon sizes from source
- **Logo Assets**: SVG/PNG logos for various contexts
- **Installer Branding**: DMG background, window styling
- **Documentation**: Branding guidelines and asset inventory

### Files Modified/Created

```
patches/ungoogled-chromium/
├── basedev-branding-strings.patch      # All string replacements
└── basedev-branding-assets.patch       # Icon/logo references

branding/
├── source/
│   ├── app-icon.svg                    # Master app icon
│   ├── logo.svg                        # BaseOne logo
│   └── wordmark.svg                    # BaseOne wordmark
├── generated/
│   ├── icons/                          # All generated icon sizes
│   ├── logos/                          # Logo variants
│   └── installer/                      # DMG/installer assets
└── scripts/
    ├── generate_icons.sh               # Icon generation
    ├── generate_logos.sh               # Logo generation
    └── apply_branding.sh               # Apply all branding

chrome/app/theme/
└── chromium/                           # Icon resources
    └── (replaced with BaseOne icons)
```

## Implementation Plan

### Phase 1: String Replacement System
- [ ] Audit all user-facing strings in Chromium
- [ ] Create comprehensive string mapping (Chromium → BaseOne)
- [ ] Generate patches for .grd/.grdp files
- [ ] Update product name constants
- [ ] Replace company/copyright information
- [ ] Update URLs and support links
- [ ] Test string replacement in all UI contexts

### Phase 2: Icon & Logo Design
- [ ] Design BaseOne app icon (1024x1024 master)
- [ ] Design BaseOne logo (multiple variants)
- [ ] Design wordmark/text logo
- [ ] Create icon generator script
- [ ] Generate all required icon sizes:
  - [ ] macOS: .icns (16-1024px)
  - [ ] Favicons: 16x16, 32x32, 48x48
  - [ ] Touch icons: 120x120, 152x152, 180x180
  - [ ] Splash screens: Various sizes
- [ ] Create logo variants:
  - [ ] Full color
  - [ ] Monochrome
  - [ ] Dark mode optimized
  - [ ] Small/compact versions

### Phase 3: Asset Integration
- [ ] Replace app icon in build
- [ ] Update favicon/tab icons
- [ ] Replace About page logo
- [ ] Update settings page branding
- [ ] Modify new tab page branding
- [ ] Update error pages
- [ ] Replace crash reporter branding

### Phase 4: Installer/Distribution
- [ ] Create DMG background image
- [ ] Design DMG window layout
- [ ] Update installer text/copy
- [ ] Generate signed .app bundle
- [ ] Create distribution package
- [ ] Test installation flow

### Phase 5: Documentation
- [ ] Create branding guidelines
- [ ] Document asset locations
- [ ] Maintain asset inventory
- [ ] Create usage examples
- [ ] Document regeneration process

## Progress Log

### 2025-11-08 - Planning
- Created feature plan
- Identified all branding touchpoints
- Researched Chromium branding system
- Planned phased implementation

### 2025-11-08 - Documentation (Continuation Session)
- Audited existing branding assets and implementation
- Created comprehensive asset inventory (branding/ASSETS.md)
- Created developer branding guide (guides/BRANDING.md)
- Documented string replacement system (352 replacements)
- Documented icon generation workflow
- Catalogued all source assets and generated files
- Identified existing work:
  - String patch: patches/ungoogled-chromium/base-branding-strings.patch (352 replacements)
  - Icon generation: features/branding/scripts/generate_icons.sh (working)
  - Generated icons: branding/generated_icons/ (complete set)
  - Source SVGs: branding/*.svg (5 variants)
- Apply string replacements to source files:
  - chromium_strings.grd: Chromium → BaseOne (global sed replacement)
  - settings_strings.grdp: "You and Google" → "Your Account"
  - shared_settings_strings.grdp: "Sync and Google services" → "Sync and Services"
- Update URLs: chrome://ungoogled-first-run → chrome://base-first-run
  - Modified ungoogled_first_run.h
  - Modified chrome_browser_main.cc
  - Modified webui_url_constants.cc
- Update macOS Info.plist files:
  - Main app: CFBundleName, CFBundleDisplayName, CFBundleIdentifier → al.base.BaseOne
  - Framework: CFBundleIdentifier → al.base.BaseOne.framework
  - All 5 Helper apps: Bundle names → "BaseOne Helper", IDs → al.base.BaseOne.helper
- Update Assets.xcassets source files:
  - AppIcon.appiconset: Replaced all 7 icon sizes (16-1024px)
  - Icon.iconset: Replaced icon_256x256.png and @2x variant
- Replace product_logo_32.png with BaseOne icon
- Rebuilt browser to compile new Assets.car
- **Known Issue**: Icon still showing as old Chromium in some contexts (deferred to later)

## Challenges & Solutions

### Challenge 1: String Coverage
**Problem**: Need to find ALL user-facing strings in Chromium codebase

**Proposed Solution**:
- Start with .grd/.grdp resource files (centralized)
- Grep for hardcoded strings
- Test in all major UI areas
- Collect feedback from testing

**Status**: Planning

### Challenge 2: Icon Format Requirements
**Problem**: macOS requires .icns format with specific sizes and 2x variants

**Proposed Solution**:
- Use iconutil or ImageMagick for conversion
- Generate from high-res SVG source
- Automate with script for consistency

**Status**: Planning

### Challenge 3: Brand Identity Design
**Problem**: Need professional, consistent brand identity

**Proposed Solution**:
- Start with simple, clean design
- Iterate based on feedback
- Maintain design system for consistency
- Document color palette and usage rules

**Status**: Planning

## Technical Details

### String Replacement Scope

Target files for string replacement:
```
chrome/app/chromium_strings.grd
chrome/app/settings_chromium_strings.grdp
chrome/app/generated_resources.grd
chrome/app/google_chrome_strings.grd
components/strings/components_strings.grd
```

String categories:
- Product names: "Chromium" → "BaseOne"
- Company names: "The Chromium Authors" → "BaseOne Team"
- URLs: chromium.org → basedev.example (TBD)
- Support links: Updated to BaseOne resources
- Copyright notices: Updated attribution

### Icon Specifications

**macOS .icns Requirements:**
- icon_16x16.png
- icon_16x16@2x.png (32px)
- icon_32x32.png
- icon_32x32@2x.png (64px)
- icon_128x128.png
- icon_128x128@2x.png (256px)
- icon_256x256.png
- icon_256x256@2x.png (512px)
- icon_512x512.png
- icon_512x512@2x.png (1024px)

**Web Icons:**
- favicon.ico (16x16, 32x32, 48x48)
- apple-touch-icon.png (180x180)
- android-chrome-192x192.png
- android-chrome-512x512.png

### Color Palette (Draft)

Primary colors TBD:
- Primary: #??????
- Secondary: #??????
- Accent: #??????
- Background: #??????
- Text: #??????

### Dependencies
- ImageMagick or iconutil (icon generation)
- Inkscape or similar (SVG → PNG)
- Optipng/pngcrush (optimization)
- Design software (Figma/Sketch/Illustrator)

### Configuration

Branding constants to update:
```cpp
// chrome/common/chrome_constants.h
#define PRODUCT_NAME "BaseOne"
#define PRODUCT_SHORT_NAME "BaseOne"
#define COMPANY_NAME "BaseOne Team"
#define COPYRIGHT_STRING "Copyright © 2025 BaseOne Team"
```

### Integration Points
- GRD/GRDP resource system
- Build system icon references
- Info.plist (macOS bundle info)
- About/settings pages
- Crash reporter
- Update system (if applicable)

## Testing

### Test Plan
- [ ] Visual inspection of all major UI areas
- [ ] About page displays correct branding
- [ ] Settings show BaseOne throughout
- [ ] No remaining "Chromium" strings visible
- [ ] Icons display correctly at all sizes
- [ ] Dock icon looks good
- [ ] Favicon displays in tabs
- [ ] Error pages show BaseOne branding
- [ ] Crash reporter (if triggered) shows BaseOne
- [ ] DMG looks professional
- [ ] Installation flow is branded

### Test Checklist

**UI Areas to Test:**
- [ ] Main window (title bar, menus)
- [ ] New Tab Page
- [ ] Settings (all sections)
- [ ] About page (chrome://about)
- [ ] Downloads page
- [ ] History page
- [ ] Extensions page
- [ ] Bookmarks manager
- [ ] Error pages (404, network error, etc.)
- [ ] Developer tools
- [ ] Context menus
- [ ] Notification/alert dialogs
- [ ] Update prompts (if applicable)

**Icon Contexts:**
- [ ] Dock/Taskbar
- [ ] App switcher (Cmd+Tab)
- [ ] Finder
- [ ] Title bar
- [ ] Tab favicon
- [ ] Bookmark favicon
- [ ] Touch Bar (if applicable)

### Test Results
- Status: Not started
- Coverage: 0%
- Issues found: None yet

## Documentation

### User Documentation
- Location: `docs/BRANDING.md` (to be created)
- Status: Needed
- Content:
  - Brand overview
  - Visual examples
  - Usage guidelines

### Developer Documentation
- Location: `guides/BRANDING.md`
- Status: **Complete** (2025-11-08)
- Content:
  - Complete branding system overview
  - String replacement system documentation
  - Icon & logo generation workflow
  - Build integration details
  - Customization guide
  - Testing checklist
  - Troubleshooting guide
  - Common tasks and workflows
  - Best practices

### Asset Inventory
- Location: `branding/ASSETS.md`
- Status: **Complete** (2025-11-08)
- Content:
  - Complete list of all assets with locations
  - Source SVGs catalog (5 variants)
  - Generated assets catalog (14+ files)
  - Sizes and formats for all icons
  - String replacement details (352 instances)
  - Usage contexts for each asset
  - Regeneration instructions with examples
  - Version control recommendations
  - Future asset needs identified

## Related

### References
- [Chromium Branding](https://www.chromium.org/developers/branding-guidelines/)
- [macOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Web App Manifest Icons](https://web.dev/add-manifest/)
- Brave Browser branding approach (for inspiration)
- Edge Browser rebrand (for reference)

### Existing Work
- `patches/ungoogled-chromium/base-branding-strings.patch` (352 replacements)
- Basic instant branding applied (Info.plist rename)
- Icon generation scripts in progress

## Outcomes

### Success Criteria
- Zero visible "Chromium" or "Google" references in UI
- Professional, consistent visual identity
- All icons render beautifully at all sizes
- Branding feels cohesive and intentional
- Easy to update/maintain branding assets
- Clear documentation for future changes

### What Worked Well
- TBD (feature in progress)

### What Could Be Improved
- TBD (feature in progress)

### Metrics
- String replacements: 352+ planned
- Icon variants: 20+ sizes/formats
- Logo variants: 5+ versions
- Build time impact: TBD
- Binary size impact: ~1-2MB (icons/logos)

## Next Steps

### Immediate Actions
1. **Design Phase**:
   - [x] Create BaseOne logo design (base.svg created)
   - [x] Design app icon (base_browser.svg created)
   - [x] Define color palette (blue/purple gradient in existing SVGs)
   - [x] Create brand guidelines (documented in guides/BRANDING.md and branding/ASSETS.md)

2. **Implementation**:
   - [x] Expand string replacement patch (352 replacements complete)
   - [x] Create icon generation pipeline (features/branding/scripts/generate_icons.sh)
   - [ ] Test branding in build (needs validation after next full build)
   - [ ] Iterate based on feedback

3. **Polish**:
   - [ ] Optimize icon file sizes
   - [ ] Ensure accessibility (color contrast)
   - [ ] Test on different display densities
   - [ ] Create installer branding

### Long-term
- [ ] Move to `progress/past/` when complete
- [ ] Update MAP.md with branding assets
- [ ] Share branding guidelines
- [ ] Maintain brand consistency in new features

## Notes

### Design Considerations

**App Icon Design Tips:**
- Keep it simple and recognizable at small sizes
- Use distinctive shape/silhouette
- Avoid too much detail
- Consider how it looks in dark mode
- Test at 16x16px to verify clarity
- Use vector source for clean scaling

**Logo Design Tips:**
- Create versatile logo (works in various contexts)
- Design for both light and dark backgrounds
- Ensure readability at small sizes
- Consider horizontal and vertical layouts
- Plan for monochrome/simplified versions

**Color Palette:**
- Choose accessible colors (WCAG AA minimum)
- Test combinations for contrast
- Consider color blindness
- Define primary, secondary, accent colors
- Document usage rules

### Branding Touchpoints Map

**High Priority** (always visible):
- App icon (Dock/Finder)
- Window title
- About page
- Settings header
- New Tab Page

**Medium Priority** (frequently visible):
- Tab favicons
- Menu items
- Error pages
- Download bar
- Extension pages

**Low Priority** (rarely visible):
- Crash reporter
- Print dialog
- Internal pages (chrome://*)
- Developer tools branding

### Asset Management Strategy

Store all source files in version control:
```
branding/
├── source/          # SVG/master files (version controlled)
├── generated/       # Generated assets (can be gitignored)
└── scripts/         # Generation scripts (version controlled)
```

Benefits:
- Source files are canonical
- Generated assets can be recreated
- Easy to update entire icon set
- Consistency across all sizes
- Smaller repo size (exclude generated)

### Implementation Priority

1. **Phase 1**: Core strings and basic icons (MVP branding)
2. **Phase 2**: Complete icon set and logos
3. **Phase 3**: Installer/distribution polish
4. **Phase 4**: Advanced branding (animations, splash screens)
5. **Phase 5**: Documentation and maintenance

### Questions to Resolve

- [ ] Final product name: "BaseOne" or "Base Browser" or other?
- [ ] Company name for copyright: "BaseOne Team" or specific entity?
- [ ] Support/website URLs: Need actual domains
- [ ] License/attribution approach: How to credit Chromium?
- [ ] Update mechanism: Auto-updates or manual downloads?
- [ ] Extension store: Use Chrome Web Store or custom?

### Resources Needed

- [ ] Designer (logo/icon creation)
- [ ] Icon generation tools installed
- [ ] Brand guidelines document
- [ ] Legal review (trademarks, attribution)
- [ ] Testing devices (various screen densities)
- [ ] User feedback mechanism
