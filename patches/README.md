# Base Core Patches

This directory contains patch files that modify Chromium source code.

## Overview

Patches are applied during the `npm run sync` process and allow us to make modifications to Chromium without maintaining a full fork.

## Patch Organization

Patches should be organized and named descriptively:
- `001-feature-name.patch` - Major features
- `fix-component-issue.patch` - Bug fixes
- `disable-unwanted-feature.patch` - Removing features

## Creating a Patch

1. Make your changes in the Chromium source tree (`../src/`)
2. Generate the patch:
   ```bash
   cd ../src
   git add -A
   git diff --staged > ../base/patches/descriptive-name.patch
   ```

3. Document the patch:
   - Add a comment at the top describing what it does
   - Update this README with the patch name and purpose

## Applying Patches

Patches are applied automatically during sync:
```bash
npm run sync
```

Or manually:
```bash
npm run apply_patches
```

## Resetting Patches

To unapply all patches:
```bash
python3 script/apply_patches.py --reset
```

## Current Patches

*Document your patches here as you add them:*

### Example Format:
- **001-custom-branding.patch** - Adds Base branding to the browser UI
- **disable-google-services.patch** - Removes additional Google service integrations

## Patch Guidelines

1. **Keep patches focused** - One logical change per patch
2. **Document thoroughly** - Explain why the patch is needed
3. **Update regularly** - Rebase patches when updating Chromium version
4. **Test thoroughly** - Ensure patches apply cleanly and don't break builds
5. **Minimize conflicts** - Avoid modifying heavily-changed Chromium code when possible

## Troubleshooting

If patches fail to apply:
1. Check if the target code has changed in the new Chromium version
2. Manually apply the changes to the new code
3. Regenerate the patch
4. Test that it applies cleanly

## Alternatives to Patches

Consider using `chromium_src/` overrides instead of patches when:
- Replacing an entire file
- Adding new files
- The change is substantial and self-contained

Patches are best for:
- Small targeted changes
- Modifications to code that can't be easily overridden
- Disabling specific features
