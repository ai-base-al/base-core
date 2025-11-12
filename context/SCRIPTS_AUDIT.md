# Script Audit - BaseOne Browser
Generated: 2025-11-11

## Summary

**Repository Structure:**
- Base-core: `/Volumes/External/BaseChrome/base-core/`
- Ungoogled-chromium: `/Volumes/External/BaseChrome/ungoogled-chromium/`
- Chromium source: `/Volumes/External/BaseChrome/ungoogled-chromium/build/src/`
- Built app: `/Volumes/External/BaseChrome/ungoogled-chromium/build/src/out/Default/BaseOne.app`

## Main Build Scripts (scripts/)

### Working Scripts (Tested & Verified)

**build_continue.sh** ✅ WORKING
- Purpose: Resume build without unpacking source
- Status: Successfully used for the 5.5 hour build
- Key features:
  - Skips source cloning/unpacking
  - Verifies bindgen exists
  - Bootstraps GN
  - Generates build files
  - Runs ninja chrome + chromedriver (54,696 targets)
- Used for: Main successful build on 2025-11-10/11

**keep_disk_active.sh** ✅ WORKING
- Purpose: Prevent external disk from disconnecting
- Status: Ran successfully during build (PID 71947)
- Key features:
  - Takes build PID as argument
  - Touches `.disk_keepalive` file every 30 seconds
  - Monitors build process with kill -0
  - Cleans up keepalive file on completion

**monitor_build.sh** ✅ WORKING
- Purpose: Track build progress every 30 minutes
- Status: Successfully monitored 11 checks over 5.5 hours
- Key features:
  - Extracts ninja progress from build log
  - Calculates percentage and ETA
  - Logs to `logs/monitor.log`
  - Sends macOS notification on completion
  - Creates `.build_complete` marker file
- Output: Logged progress from 19.5% to 100%

**post_build.sh** ✅ READY (Not yet used)
- Purpose: Automated post-build git workflow
- Status: Ready to use, interactive prompts
- Key features:
  - Checks for `.build_complete` marker
  - Commits new scripts to main
  - Interactive branch cleanup
  - Creates feature branch from progress/
  - Provides git push instructions
- Note: We ran this workflow manually instead

### Other Build Scripts (Need Review)

**build.sh** ⚠️  NEEDS REVIEW
- Purpose: TBD - need to check if this is old or current
- Action needed: Review and determine if still needed

**clone.sh** ⚠️ NEEDS REVIEW
- Purpose: Likely clones ungoogled-chromium repo
- Action needed: Check if compatible with current structure

**init.sh** ⚠️ NEEDS REVIEW
- Purpose: Likely initial setup script
- Action needed: Verify paths for new structure

**patch.sh** ⚠️ NEEDS REVIEW
- Purpose: Apply patches to source
- Action needed: Check patch locations

**sync.sh** ⚠️ NEEDS REVIEW
- Purpose: Likely syncs with upstream
- Action needed: Review functionality

## Branding Scripts (features/branding/scripts/)

### String Replacement Scripts

**replace_strings.sh** ⚠️ NEEDS PATH UPDATE
- Purpose: Replace "Chromium" with "BaseOne" in source strings
- Status: Has old paths
- Current path calculation:
  ```bash
  ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
  SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"
  ```
- Issues:
  - Assumes features/branding/scripts is 3 levels deep
  - Should navigate to base-core root then to ungoogled-chromium
- Files it modifies:
  - chrome/app/chromium_strings.grd
  - chrome/app/settings_chromium_strings.grdp
  - chrome/app/generated_resources.grd
  - etc. (22 replacements per file)
- Action needed: Update path calculation

**find_chromium_strings.sh** ⚠️ NEEDS PATH UPDATE
- Purpose: Find all instances of "Chromium" in source for string replacement
- Status: Likely has old paths
- Action needed: Update paths, verify grep patterns

### Icon Generation Scripts

**generate_icons.sh** ⚠️ NEEDS REVIEW
- Purpose: Generate all icon sizes from master SVG
- Status: Icons exist in features/branding/icons/
- Generated files:
  - app.icns (84KB)
  - base_icon_16.png through base_icon_1024.png
  - product_logo files with @2x variants
- Action needed: Verify script works with current setup

**generate_icon.sh** ⚠️ NEEDS REVIEW (singular)
- Purpose: Likely generates single icon
- Action needed: Check if this is a helper or standalone

### Branding Application Scripts

**apply.sh** (features/branding/) ⚠️ NEEDS PATH UPDATE
- Purpose: Apply complete BaseOne branding
- Status: Has old paths
- Current path calculation:
  ```bash
  ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
  SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"
  ```
- Issues: Assumes features/branding is 2 levels deep
- What it does:
  1. Updates chrome/app/theme/chromium/BRANDING file
  2. Updates product name constants
  3. Replaces icons
  4. Updates Info.plist entries
- Action needed: Update path calculations

**apply_instant.sh** (features/branding/) ⚠️ NEEDS PATH UPDATE
- Purpose: Quick branding of existing Chromium.app (no rebuild)
- Status: FAILED - couldn't find app
- Current path calculation:
  ```bash
  ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
  APP_DIR="$ROOT_DIR/ungoogled-chromium/build/src/out/Default"
  ```
- Issues: Path calculation results in wrong location
- What it does:
  - Renames Chromium.app to "BaseOne.app"
  - Updates CFBundleName, CFBundleIdentifier, CFBundleDisplayName
- Action needed: Fix path or update to use absolute path

**workflow_test_strings.sh** (features/branding/) ℹ️ INFO
- Purpose: Likely a test workflow
- Action needed: Review to see if still needed

**rollback.sh** (features/branding/) ℹ️ INFO
- Purpose: Rollback branding changes
- Action needed: Verify it works with current structure

## Path Issues Summary

### Problem
All branding scripts use relative path calculations that assume an old repository structure:
```
Base/
├── ungoogled-chromium/
│   └── build/src/
└── features/branding/
```

### Current Structure
```
/Volumes/External/BaseChrome/
├── base-core/                    # This repo (git root)
│   ├── features/branding/
│   ├── scripts/
│   └── ...
└── ungoogled-chromium/           # Submodule/separate repo
    └── build/src/
```

### Fix Needed
Update path calculations in:
1. `features/branding/scripts/replace_strings.sh`
2. `features/branding/apply.sh`
3. `features/branding/apply_instant.sh`
4. `features/branding/scripts/find_chromium_strings.sh`
5. Any other branding scripts

### Recommended Approach
Use absolute paths from a config file or calculate correctly from git root:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(git rev-parse --show-toplevel)"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
SRC_DIR="$UNGOOGLED_DIR/build/src"
```

## Immediate Actions Required

1. **Fix branding script paths**
   - Priority: HIGH
   - Scripts affected: All features/branding/ scripts
   - Impact: Cannot apply branding to source before build

2. **Review old build scripts**
   - Priority: MEDIUM
   - Scripts: build.sh, clone.sh, init.sh, patch.sh, sync.sh
   - Action: Determine which are still needed

3. **Test branding workflow end-to-end**
   - Priority: MEDIUM
   - After fixing paths, test full branding application
   - Verify string replacements work correctly

4. **Document script usage**
   - Priority: LOW
   - Add usage examples to MAP.md
   - Create workflow documentation

## Current Workaround

For instant branding (Info.plist only):
```bash
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src/out/Default
mv Chromium.app "BaseOne.app"
/usr/libexec/PlistBuddy -c "Set :CFBundleName 'BaseOne'" "BaseOne.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier al.base.BaseOne" "BaseOne.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 'BaseOne'" "BaseOne.app/Contents/Info.plist"
```

Status: ✅ WORKING (used successfully on 2025-11-11)

## Next Steps

1. Create issue/branch for fixing branding script paths
2. Update scripts with correct path calculations
3. Test complete branding workflow
4. Document proper branding process in guides/
5. Clean up unused scripts
