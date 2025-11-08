# Cleanup Plan - Remove Broken Scripts

**Goal:** Remove all scripts that bypass ungoogled-chromium's build system and break the source tree.

---

## Scripts to DELETE

### `/scripts/` - All 9 files (These bypass ungoogled-chromium)

**Why delete:** These scripts try to build Chromium directly, causing:
- Patch conflicts
- Modified source tree
- Can't use ungoogled-chromium updates
- Exactly the problems we just debugged

```bash
rm -rf /Volumes/External/BaseChrome/base-core/scripts/
```

**Files being deleted:**
- `1_clone_source.sh` - Duplicates ungoogled-chromium/build.sh
- `2_download_dependencies.sh` - Duplicates upstream
- `3_apply_branding.sh` - Modifies source (wrong approach)
- `4_apply_strings.sh` - Modifies source (wrong approach)
- `5_build_full.sh` - Bypasses ungoogled-chromium
- `5_configure_build.sh` - Bypasses ungoogled-chromium
- `6_build_incremental.sh` - Bypasses ungoogled-chromium
- `7_apply_strings_and_build.sh` - Bypasses ungoogled-chromium
- `backup_build.sh` - Keep this one (move to /build/)
- `restore_build.sh` - Keep this one (move to /build/)

### `/run/` - All 15 experimental files

**Why delete:** Python version experiments that break the build

```bash
rm -rf /Volumes/External/BaseChrome/base-core/run/
```

**Files being deleted:**
- `1_update_chromium.sh` - Experimental
- `2_build_binaries.sh` - Experimental
- `2a_build_with_python314_fix.sh` - Failed experiment
- `2b_build_force_python311.sh` - Failed experiment
- `2c_build_smart.sh` - Failed experiment
- `3_check_build_status.sh` - Experimental
- `3_smart_build.sh` - Experimental
- `3b_build_latest_depot_tools.sh` - Experimental
- `4_build_with_python313.sh` - Experimental
- `4_stop_build.sh` - Helper (not harmful but not needed)
- `5_build_macos.sh` - Experimental
- `5_clean_build.sh` - Experimental
- `6_rebuild_only.sh` - We just tried this, failed with safe_browsing error
- `6_setup_python.sh` - Experimental
- `check_status.sh` - Helper
- `menu.sh` - Menu for experimental scripts
- `test_browser.sh` - Keep this one (move to /build/)

### `/tools/script/` - 3 duplicate files

**Why delete:** Exact duplicates of ungoogled-chromium scripts

```bash
rm -rf /Volumes/External/BaseChrome/base-core/tools/script/
```

**Files being deleted:**
- `build.sh` - Duplicate of ungoogled-chromium/build.sh
- `retrieve_and_unpack_resource.sh` - Duplicate of ungoogled-chromium/retrieve_and_unpack_resource.sh
- `sign_and_package_app.sh` - Duplicate of ungoogled-chromium/sign_and_package_app.sh

### `/tools/fix_depot_tools.sh` - Keep but move

**Keep:** This fixes Python 3.14 compatibility
**Action:** Move to `/build/tools/`

---

## Scripts to KEEP

### `/ungoogled-chromium/` - All files (UPSTREAM, never touch)

**Keep:** This is upstream code
**Action:** None - never modify

**Critical files:**
- `build.sh` - Main build entry point
- `retrieve_and_unpack_resource.sh` - Download dependencies
- `sign_and_package_app.sh` - Create DMG

### `/features/branding/` - All files (Our feature modules)

**Keep:** These are our feature implementations
**Action:** None - these work correctly

**Files:**
- `apply.sh` - Post-build branding (modifies binary, not source)
- `apply_instant.sh` - Quick branding
- `config.sh` - Branding config
- `rollback.sh` - Undo branding
- `scripts/*.sh` - Icon generation, string replacement

---

## New Structure After Cleanup

```
base-core/
├── ARCHITECTURE.md              # Architecture documentation (NEW)
├── CLEANUP_PLAN.md              # This file (NEW)
├── MAP.md                       # Repository map (existing)
│
├── ungoogled-chromium/          # UPSTREAM (never modify)
│   ├── build.sh                 # Main build script
│   ├── retrieve_and_unpack_resource.sh
│   ├── sign_and_package_app.sh
│   └── build/src/               # Chromium source (auto-managed)
│
├── patches/                     # Our patches
│   ├── series                   # Patch order
│   └── ungoogled-chromium/
│       └── disable-rust-version-check.patch
│
├── features/                    # Feature modules
│   └── branding/
│       ├── apply.sh             # Post-build branding
│       ├── resources/           # Icons, strings
│       └── scripts/             # Asset generation
│
├── build/                       # Build utilities (NEW)
│   ├── build.sh                 # Main build wrapper (NEW)
│   ├── rebuild.sh               # Incremental rebuild (NEW)
│   ├── backup.sh                # Backup builds (moved from scripts/)
│   ├── restore.sh               # Restore builds (moved from scripts/)
│   ├── test.sh                  # Test browser (moved from run/)
│   └── tools/
│       └── fix_depot_tools.sh   # Python 3.14 fix (moved from tools/)
│
├── binaries/                    # Build output
│   ├── Base Dev.app
│   └── backups/
│
└── build/download_cache/        # Dependency cache
```

---

## Migration Steps

### Step 1: Create /build/ directory

```bash
mkdir -p /Volumes/External/BaseChrome/base-core/build/tools
```

### Step 2: Move keepers to /build/

```bash
# Move backup/restore scripts
mv /Volumes/External/BaseChrome/base-core/scripts/backup_build.sh \
   /Volumes/External/BaseChrome/base-core/build/backup.sh

mv /Volumes/External/BaseChrome/base-core/scripts/restore_build.sh \
   /Volumes/External/BaseChrome/base-core/build/restore.sh

# Move test script
mv /Volumes/External/BaseChrome/base-core/run/test_browser.sh \
   /Volumes/External/BaseChrome/base-core/build/test.sh

# Move depot_tools fix
mv /Volumes/External/BaseChrome/base-core/tools/fix_depot_tools.sh \
   /Volumes/External/BaseChrome/base-core/build/tools/fix_depot_tools.sh
```

### Step 3: Delete broken scripts

```bash
# Delete /scripts/ (all bypass ungoogled-chromium)
rm -rf /Volumes/External/BaseChrome/base-core/scripts/

# Delete /run/ (all experimental/broken)
rm -rf /Volumes/External/BaseChrome/base-core/run/

# Delete /tools/script/ (duplicates)
rm -rf /Volumes/External/BaseChrome/base-core/tools/script/
```

### Step 4: Create new build scripts

Create `/build/build.sh`:
```bash
#!/bin/bash
# Main Base Chrome build script
# Wraps ungoogled-chromium/build.sh with our patches

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Apply depot_tools fix
"$ROOT_DIR/build/tools/fix_depot_tools.sh"

# Run ungoogled-chromium build (applies our patches automatically)
cd "$ROOT_DIR/ungoogled-chromium"
./build.sh "$@"

# Apply post-build branding
"$ROOT_DIR/features/branding/apply.sh" "$ROOT_DIR/ungoogled-chromium/build/src/out/Default/Chromium.app"
```

Create `/build/rebuild.sh`:
```bash
#!/bin/bash
# Incremental rebuild (only changed files)

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"

cd "$SRC_DIR"

# Just rebuild
ninja -C out/Default chrome

# Re-apply branding
"$ROOT_DIR/features/branding/apply.sh" "out/Default/Chromium.app"
```

### Step 5: Clean source tree

```bash
cd /Volumes/External/BaseChrome/base-core/ungoogled-chromium/build/src
git checkout .          # Revert all modifications
git clean -fd           # Remove untracked files
rm -rf out/             # Remove build artifacts
```

### Step 6: Test clean build

```bash
cd /Volumes/External/BaseChrome/base-core
./build/build.sh -d     # -d = don't re-download source
```

---

## Expected Results

### Before Cleanup
- 49 scripts scattered across /scripts/, /run/, /tools/
- Source tree modified (BUILD.gn patched directly)
- Patch conflicts (safe_browsing error)
- Can't update ungoogled-chromium
- Confusing which script to use

### After Cleanup
- 7 scripts in organized structure
- Source tree clean (patches applied via patch system)
- No patch conflicts
- Can update ungoogled-chromium anytime
- Clear entry points: `./build/build.sh`, `./build/rebuild.sh`

---

## Risk Assessment

### Low Risk (Safe to delete)
- `/run/*.sh` - All experimental, never worked properly
- `/tools/script/*.sh` - Exact duplicates of upstream
- Most of `/scripts/*.sh` - Bypass ungoogled-chromium

### Medium Risk (Verify first)
- `/scripts/backup_build.sh` - Used, but simple to recreate
- `/scripts/restore_build.sh` - Used, but simple to recreate

### No Risk (Keep)
- `/ungoogled-chromium/*` - Upstream code
- `/features/branding/*` - Working feature modules
- `/patches/*` - Our patches

---

## Rollback Plan

If cleanup causes issues:

```bash
# Restore from git
cd /Volumes/External/BaseChrome/base-core
git checkout scripts/ run/ tools/

# Or restore from backup (if you created one)
cp -r /path/to/backup/scripts/ .
cp -r /path/to/backup/run/ .
cp -r /path/to/backup/tools/ .
```

---

## Verification Checklist

After cleanup, verify:

- [ ] Source tree is clean (no modifications in ungoogled-chromium/build/src/)
- [ ] Patches apply cleanly (no conflicts)
- [ ] Build completes successfully
- [ ] Browser runs correctly
- [ ] Branding applies correctly
- [ ] Can update ungoogled-chromium without conflicts

---

## Timeline

1. **Now:** Review ARCHITECTURE.md and CLEANUP_PLAN.md
2. **Now:** Execute cleanup (Steps 1-3)
3. **Now:** Create new build scripts (Step 4)
4. **Now:** Clean source tree (Step 5)
5. **Next:** Test clean build (Step 6)
6. **Next:** Verify everything works

Total time: ~30 minutes of work + 2-4 hours build time

---

Generated: 2025-11-08
