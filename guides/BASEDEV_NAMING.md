# BaseDev Naming Convention

## Overview

All custom features, panels, and modifications for Base Browser use the `basedev_` prefix to clearly distinguish them from Chromium's built-in components. This makes it easy to:

1. Identify our customizations at a glance
2. Avoid naming conflicts with upstream Chromium
3. Keep our patches organized and maintainable
4. Track what gets affected when merging upstream changes

## Naming Rules

### 1. Patch Files
Location: `/patches/ungoogled-chromium/`

Format: `basedev-{category}-{feature}.patch`

Examples:
- `basedev-sidepanel-reading.patch` - Reading mode side panel
- `basedev-sidepanel-notes.patch` - Notes side panel
- `basedev-toolbar-custom.patch` - Custom toolbar button
- `basedev-settings-privacy.patch` - Privacy settings

### 2. Source Directories
Location: `chrome/browser/ui/`

Format: `{path}/basedev_{feature}/`

Examples:
- `chrome/browser/ui/webui/side_panel/basedev_reading/`
- `chrome/browser/ui/webui/side_panel/basedev_notes/`
- `chrome/browser/ui/views/side_panel/basedev_reading_mode_side_panel_coordinator.h`

### 3. C++ Classes
Format: `BaseDev{Feature}{Component}`

Examples:
- `BaseDevReadingModeUI` - WebUI controller
- `BaseDevReadingModeSidePanelCoordinator` - Side panel coordinator
- `BaseDevNotesManager` - Notes manager

### 4. Enum Values
Format: `kBaseDev{Feature}`

Examples:
```cpp
enum class Id {
  kAssistant,
  kBookmarks,
  kBaseDevReadingMode,  // Our custom panel
  kBaseDevNotes,        // Our custom panel
  kReadingList,
  // ...
};
```

### 5. Mojom Modules
Format: `basedev_{feature}.mojom`

Module name: `basedev_{feature}.mojom`

Examples:
```mojom
// File: basedev_reading.mojom
module basedev_reading.mojom;

interface PageHandler {
  ExtractContent(url.mojom.Url url);
};
```

### 6. URL Constants
Format:
- Host: `basedev-{feature}-{purpose}`
- URL: `chrome://basedev-{feature}-{purpose}/`

Examples:
```cpp
inline constexpr char kChromeUIBaseDevReadingSidePanelHost[] =
    "basedev-reading-side-panel";
inline constexpr char kChromeUIBaseDevReadingSidePanelURL[] =
    "chrome://basedev-reading-side-panel/";
```

### 7. Resource Files
Format: `basedev_{feature}.{ext}`

Examples:
- `basedev_reading.html`
- `basedev_reading.css`
- `basedev_reading.ts`
- `basedev_reading.js` (compiled TypeScript)

### 8. Resource IDs
Format: `IDS_BASEDEV_{FEATURE}_{PURPOSE}`

Examples:
```cpp
#define IDS_BASEDEV_READING_MODE_TITLE       "Reading Mode"
#define IDS_BASEDEV_READING_MODE_FONT_SIZE   "Font Size"
#define IDS_BASEDEV_NOTES_TITLE              "Notes"
```

### 9. GRD Resource Files
Format: `basedev_{feature}_resources.grd`

Examples:
- `basedev_reading_resources.grd`
- `basedev_reading_resources.pak`
- `basedev_reading_resources_map.cc`

### 10. Preference Keys
Format: `basedev.{feature}.{setting}`

Examples:
```cpp
profile->GetPrefs()->SetInteger("basedev.reading_mode.font_size", size);
profile->GetPrefs()->SetString("basedev.reading_mode.theme", theme);
profile->GetPrefs()->SetBoolean("basedev.notes.auto_save", true);
```

### 11. Feature Flags
Format: `kBaseDevEnableFeature{Feature}`

Examples:
```cpp
BASE_FEATURE(kBaseDevEnableFeatureReadingMode,
             "BaseDevEnableFeatureReadingMode",
             base::FEATURE_ENABLED_BY_DEFAULT);
```

## Directory Structure Example

```
chrome/browser/
├── ui/
│   ├── views/
│   │   └── side_panel/
│   │       ├── basedev_reading_mode_side_panel_coordinator.h
│   │       ├── basedev_reading_mode_side_panel_coordinator.cc
│   │       ├── basedev_notes_side_panel_coordinator.h
│   │       └── basedev_notes_side_panel_coordinator.cc
│   └── webui/
│       └── side_panel/
│           ├── basedev_reading/
│           │   ├── basedev_reading_ui.h
│           │   ├── basedev_reading_ui.cc
│           │   ├── basedev_reading.mojom
│           │   └── BUILD.gn
│           └── basedev_notes/
│               ├── basedev_notes_ui.h
│               ├── basedev_notes_ui.cc
│               ├── basedev_notes.mojom
│               └── BUILD.gn
└── resources/
    └── side_panel/
        ├── basedev_reading/
        │   ├── basedev_reading.html
        │   ├── basedev_reading.css
        │   ├── basedev_reading.ts
        │   └── BUILD.gn
        └── basedev_notes/
            ├── basedev_notes.html
            ├── basedev_notes.css
            ├── basedev_notes.ts
            └── BUILD.gn
```

## Benefits

### 1. Easy Identification
```bash
# Find all BaseDev customizations
grep -r "basedev_" chrome/browser/ui/
grep -r "BaseDev" chrome/browser/ui/
grep "basedev-" patches/ungoogled-chromium/
```

### 2. Clear Ownership
- `kBookmarks` → Chromium's bookmarks panel
- `kBaseDevReadingMode` → Our reading mode panel

### 3. Conflict Avoidance
If Chromium adds a `reading_mode` feature, it won't conflict with our `basedev_reading`.

### 4. Patch Organization
```
patches/ungoogled-chromium/
├── base-branding-strings.patch          # Core branding
├── basedev-sidepanel-reading.patch      # Feature: Reading mode
├── basedev-sidepanel-notes.patch        # Feature: Notes
└── basedev-toolbar-custom.patch         # Feature: Custom toolbar
```

### 5. Upstream Merging
When merging upstream changes:
- Chromium changes → likely don't affect `basedev_*` code
- Our patches → easy to identify and rebase

## Quick Reference Table

| Component | Format | Example |
|-----------|--------|---------|
| Patch file | `basedev-{category}-{feature}.patch` | `basedev-sidepanel-reading.patch` |
| Directory | `basedev_{feature}/` | `basedev_reading/` |
| C++ class | `BaseDev{Feature}{Component}` | `BaseDevReadingModeUI` |
| Enum value | `kBaseDev{Feature}` | `kBaseDevReadingMode` |
| Mojom module | `basedev_{feature}.mojom` | `basedev_reading.mojom` |
| URL host | `basedev-{feature}-{purpose}` | `basedev-reading-side-panel` |
| Resource ID | `IDS_BASEDEV_{FEATURE}_{PURPOSE}` | `IDS_BASEDEV_READING_MODE_TITLE` |
| Pref key | `basedev.{feature}.{setting}` | `basedev.reading_mode.font_size` |
| Feature flag | `kBaseDevEnable{Feature}` | `kBaseDevEnableReadingMode` |

## Comments in Code

Always mark custom code with comments:

```cpp
// BaseDev: Custom reading mode panel
class BaseDevReadingModeUI : public ui::MojoBubbleWebUIController {
  // ...
};

// BaseDev: Add custom side panel entry
enum class Id {
  kBookmarks,
  kBaseDevReadingMode,  // BaseDev: Reading mode panel
  kReadingList,
};
```

This helps:
- Future developers understand what's custom
- Code reviewers identify Base-specific changes
- Automated tools track our modifications

## Migration from Old Code

If you have existing code without the `basedev_` prefix, migrate it:

1. **Create new files** with proper naming
2. **Copy content** and update class/function names
3. **Update all references** in other files
4. **Test thoroughly**
5. **Create new patch** file
6. **Delete old files** and patch

Example migration:
```bash
# Old (bad)
chrome/browser/ui/webui/side_panel/reading_mode/reading_mode_ui.h

# New (good)
chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading_ui.h
```

## Exceptions

The only exception to this rule is the **base-branding-strings.patch** which modifies Chromium's built-in strings. This uses `base-` prefix instead of `basedev-` because it's modifying existing Chromium code, not adding new features.

```
base-branding-strings.patch     ← Exception: modifies Chromium strings
basedev-sidepanel-reading.patch ← Standard: adds new feature
basedev-sidepanel-notes.patch   ← Standard: adds new feature
```

## Checklist

Before committing custom code, verify:

- [ ] All directories use `basedev_{feature}/`
- [ ] All C++ classes use `BaseDev{Feature}` prefix
- [ ] All enum values use `kBaseDev{Feature}`
- [ ] All URL constants use `basedev-{feature}-{purpose}`
- [ ] All resource IDs use `IDS_BASEDEV_{FEATURE}_{PURPOSE}`
- [ ] All Mojom modules use `basedev_{feature}.mojom`
- [ ] All patch files use `basedev-{category}-{feature}.patch`
- [ ] All preference keys use `basedev.{feature}.{setting}`
- [ ] Code comments mark sections as "BaseDev:"

## See Also

- [SIDEPANEL.md](./SIDEPANEL.md) - Complete side panel implementation guide
- [tools/README.md](../tools/README.md) - Side panel generator documentation
- [MAP.md](../MAP.md) - Repository structure
