# String Replacements - Base Dev Branding

Complete list of smart string replacements applied to make "Base Dev" appear throughout the UI.

## What Gets Replaced

### ✅ User-Facing Strings (SAFE to replace)

1. **Window Titles**
   - `Chromium - Page Title` → `Base Dev - Page Title`
   - `Page Title - Chromium` → `Page Title - Base Dev`

2. **About Dialog**
   - `About Chromium` → `About Base Dev`
   - `About &Chromium` → `About Base Dev`

3. **Copyright Notice**
   - Original: `Copyright 2025 The Chromium Authors. All rights reserved.`
   - New: `Copyright 2025 BaseCode LLC. Based on Chromium, Copyright The Chromium Authors.`
   - **Preserves Chromium attribution** ✓

4. **UI Messages**
   - `sign in to Chromium` → `sign in to Base Dev`
   - `signed in to Chromium` → `signed in to Base Dev`
   - `make Chromium better` → `make Base Dev better`

5. **Logos and Alt Text**
   - `Chromium logo` → `Base Dev logo`
   - `Chromium Enterprise logo` → `Base Dev Enterprise logo`

6. **Settings**
   - `About Chromium` (menu) → `About Base Dev`
   - Settings page titles

### ❌ What DOESN'T Get Replaced (SAFE to keep)

1. **Internal Identifiers**
   - `chromium` (lowercase) - code identifiers
   - File paths, class names, function names

2. **Attribution**
   - `Chromium open source project` - credit preserved
   - `The Chromium Authors` - in attribution text
   - Links to chromium.org

3. **Other Products**
   - `ChromiumOS` - different product
   - `Chromium Embedded Framework`

4. **Code Comments**
   - Technical documentation
   - Source code comments

## Files Modified

- `chrome/app/chromium_strings.grd` - Main branded strings
- `chrome/app/settings_chromium_strings.grdp` - Settings strings

## Example Changes

### Before:
```xml
<message name="IDS_ABOUT" desc="About menu item">
  About &Chromium
</message>

<message name="IDS_ABOUT_VERSION_COPYRIGHT">
  Copyright <ph name="YEAR">{0,date,y}</ph> The Chromium Authors.
</message>
```

### After:
```xml
<message name="IDS_ABOUT" desc="About menu item">
  About Base Dev
</message>

<message name="IDS_ABOUT_VERSION_COPYRIGHT">
  Copyright <ph name="YEAR">{0,date,y}</ph> BaseCode LLC. Based on Chromium, Copyright The Chromium Authors.
</message>
```

## Attribution Compliance

The replacements maintain proper attribution:

✅ **Chromium project credit preserved**
✅ **Original copyright notice included**
✅ **Links to Chromium project maintained**
✅ **Compliant with Chromium license (BSD-3-Clause)**

## Usage

```bash
# Apply string replacements
./features/branding/scripts/replace_strings.sh

# Review changes
cd ungoogled-chromium/build/src
git diff chrome/app/chromium_strings.grd

# Build with new strings
cd /Volumes/External/BaseChrome/base-core
./run/6_rebuild_only.sh

# Rollback if needed
for f in $(find chrome/app -name '*.brandorig'); do
  mv "$f" "${f%.brandorig}"
done
```

## Build Time

After string replacement: **10-20 minutes** (only UI strings recompile)

## Verification

After building, verify:
1. About dialog says "About Base Dev"
2. Copyright shows "BaseCode LLC. Based on Chromium..."
3. Window titles show "Base Dev"
4. No "Chromium" in user-visible UI (except attribution)

## Configuration

Edit `features/branding/config.sh`:
```bash
export PRODUCT_NAME="Your Product"
export COMPANY_NAME="Your Company"
```

Then re-run `replace_strings.sh`.