# Base Dev String Branding Patch

Date: 2025-11-08

## What This Does

This patch changes internal browser strings from "Chromium" to "Base Dev" throughout the browser interface.

## Files Modified

The patch modifies two key string resource files:

1. `chrome/app/chromium_strings.grd` - Main browser strings
2. `chrome/app/settings_chromium_strings.grdp` - Settings page strings

## Key String Replacements

### Product Names
- "Chromium" → "Base Dev"
- Product name appears in menus, dialogs, settings

### User-Facing Strings
- "About Chromium" → "About Base Dev"
- "Chromium history" → "Base Dev history"
- "Make Chromium the default browser" → "Make Base Dev the default browser"
- "Update Chromium" → "Update Base Dev"
- "Chromium is your default browser" → "Base Dev is your default browser"
- Plus ~40 other UI strings

### Helper Process Names
- "Chromium Helper" → "Base Dev Helper"
- "Chromium Helper (Alerts)" → "Base Dev Helper (Alerts)"

## How It Works

This is applied via ungoogled-chromium's patch system:

1. Patch file: `/patches/ungoogled-chromium/base-branding-strings.patch`
2. Registered in: `/patches/series`
3. Applied automatically by: `ungoogled-chromium/build.sh` (line 43)

## Testing

After building with this patch:

```bash
# Build will apply patch automatically
./build/build.sh

# Or incremental rebuild
./build/rebuild.sh
```

Then check:
1. About menu shows "About Base Dev"
2. Window titles show "Base Dev"
3. Settings show "Base Dev is your default browser"
4. Help text references "Base Dev"

## Important Notes

### What This Changes
- Internal UI strings visible to users
- Menu items, dialogs, settings pages
- Window titles and process names

### What This DOESN'T Change
- Application bundle name (still Chromium.app until post-build branding)
- File paths and internal identifiers
- Code references (those aren't user-visible)

### Post-Build Branding Still Needed
This patch only changes strings. You still need to run:
```bash
./features/branding/apply.sh
```
To apply:
- App bundle renaming (Chromium.app → Base Dev.app)
- Icon replacements
- Info.plist modifications

## String Coverage

This patch covers the most visible strings:
- Menu bar items (macOS)
- Window titles
- Dialog boxes
- Settings pages
- Error messages
- Update notifications
- Default browser prompts

Total replacements: ~50 unique strings across 2 files

## Future Enhancements

To cover ALL strings (there are 300+ total), expand this patch to include:
- `chrome/app/generated_resources.grd`
- Additional `.grdp` files for specific features
- Platform-specific string files

## The Correct Way

Following the Brave/Edge pattern:
1. Never modify source directly
2. Create unified diff patch
3. Add to patches/series
4. Let build.sh apply it
5. Clean source tree, no conflicts

This is the same approach used by all major Chromium forks.
