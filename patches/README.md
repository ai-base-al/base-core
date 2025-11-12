# BaseOne Patches

This directory contains patch files that modify the Chromium source code to create BaseOne Browser.

## Overview

Patches allow us to make targeted modifications to Chromium without maintaining a full fork. Each patch should do one thing well (Unix philosophy).

## Current Patch Organization

```
patches/
├── series                                    # Patch application order
├── README.md                                 # This file
└── baseone-complete-icon-branding.patch     # Icon branding (binary files)
```

## Patch Categories

### Branding
- baseone-complete-icon-branding.patch - Complete BaseOne icon branding (PNG, SVG, ICNS files)

### Features
(No feature patches yet - sidepanels will go here)

### Privacy & Security
(Privacy enhancements will go here)

## Applying Patches

Patches are applied automatically by the apply_base.sh script:

```bash
# Apply all patches in order
cd /Volumes/External/BaseChrome/base-core
./scripts/apply_base.sh
```

This script:
1. Reads patches/series file
2. Applies each patch to ungoogled-chromium/build/src/
3. Runs branding scripts (strings + icons)
4. Shows summary of modified files

## Creating a New Patch

### 1. Make changes in Chromium source

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src
# Make your code changes
git add -A
```

### 2. Generate the patch

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src
git diff --staged > /Volumes/External/BaseChrome/base-core/patches/my-feature.patch
```

### 3. Add to series file

Edit `/Volumes/External/BaseChrome/base-core/patches/series` and add your patch:

```
# Existing patches
baseone-complete-icon-branding.patch

# My new feature
my-feature.patch
```

### 4. Test the patch

```bash
cd /Volumes/External/BaseChrome/base-core
./scripts/apply_base.sh
```

### 5. Document the patch

Add an entry to this README under the appropriate category.

## Patch Naming Convention

Follow these conventions for consistency:

- baseone-{category}-{description}.patch - Core BaseOne modifications
- basedev-{category}-{description}.patch - BaseDev specific features
- fix-{component}-{issue}.patch - Bug fixes
- disable-{feature}.patch - Feature removal

Examples:
- baseone-branding-icons.patch
- basedev-sidepanel-reading.patch
- fix-keychain-access.patch
- disable-google-sync.patch

## Incremental Builds

After applying patches, use incremental builds:

```bash
cd /Volumes/External/BaseChrome/base-core
./scripts/build_incremental.sh
```

This rebuilds only changed files (10-30 minutes vs 2-4 hours for full build).

## Resetting Source

To reset the Chromium source to clean state:

```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src
git reset --hard HEAD
git clean -fd
```

Then reapply patches:

```bash
cd /Volumes/External/BaseChrome/base-core
./scripts/apply_base.sh
```

## Patch Guidelines

1. **Small and focused** - One logical change per patch
2. **Well-documented** - Clear comments explaining what and why
3. **Tested** - Must apply cleanly and build successfully
4. **Maintained** - Update when rebasing to new Chromium versions
5. **Reversible** - Should be possible to unapply safely

## Troubleshooting

### Patch fails to apply

```bash
patch: **** malformed patch at line X
```

**Solution**: The patch may have been corrupted or is from a different Chromium version. Regenerate the patch.

### Merge conflicts

When updating Chromium versions, patches may conflict:

1. Apply patches one by one to identify the conflicting patch
2. Manually apply the changes to the new code
3. Regenerate the patch
4. Update series file if needed

### Build fails after applying patches

1. Check that all patches applied successfully
2. Review the patch changes - may conflict with each other
3. Try applying patches in different order
4. Check build logs for specific errors

## Binary File Patches

Some patches include binary files (icons, images). These use git's binary diff format:

```
diff --git a/path/to/file.png b/path/to/file.png
index abc123..def456 100644
GIT binary patch
literal 1234
...base85 encoded data...
```

## Next Steps

Before adding new features:
1. Ensure current patches are well-organized
2. Confirm incremental builds work
3. Document setup process completely
4. Test on clean system

See /Volumes/External/BaseChrome/base-core/docs/ for:
- SETUP.md - Complete setup guide for new laptops
- BRANDING.md - Branding application process
- BUILD.md - Build system documentation
