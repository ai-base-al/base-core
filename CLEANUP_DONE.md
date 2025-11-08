# Cleanup Complete

**Date:** 2025-11-08

## What Was Done

### Deleted (27 broken scripts)
- `/scripts/` - 9 files that bypassed ungoogled-chromium
- `/run/` - 15 experimental Python version scripts
- `/tools/script/` - 3 duplicate files

### Moved (4 keeper scripts)
- `scripts/backup_build.sh` → `build/backup.sh`
- `scripts/restore_build.sh` → `build/restore.sh`
- `run/test_browser.sh` → `build/test.sh`
- `tools/fix_depot_tools.sh` → `build/tools/fix_depot_tools.sh`

### Created (2 new clean scripts)
- `build/build.sh` - Main build wrapper (calls ungoogled-chromium/build.sh)
- `build/rebuild.sh` - Incremental rebuild (only changed files)

---

## New Clean Structure

```
base-core/
├── ARCHITECTURE.md          # How everything works
├── CLEANUP_PLAN.md          # What we planned
├── CLEANUP_DONE.md          # This file (what we did)
├── MAP.md                   # Repository map
│
├── ungoogled-chromium/      # UPSTREAM (never modify)
│   ├── build.sh
│   └── build/src/           # Source (managed by build.sh)
│
├── patches/                 # Our patches only
│   ├── series
│   └── ungoogled-chromium/
│       └── disable-rust-version-check.patch
│
├── features/                # Feature modules
│   └── branding/
│
├── build/                   # Build utilities (NEW!)
│   ├── build.sh             # Main build
│   ├── rebuild.sh           # Incremental rebuild
│   ├── backup.sh            # Backup builds
│   ├── restore.sh           # Restore builds
│   ├── test.sh              # Test browser
│   └── tools/
│       └── fix_depot_tools.sh
│
└── binaries/                # Build output
    ├── Base Dev.app
    └── backups/
```

---

## What Changed

### Before Cleanup
```bash
# Confusing - which script to use?
./scripts/5_build_full.sh
./scripts/6_build_incremental.sh
./run/5_build_macos.sh
./run/6_rebuild_only.sh
# ... 49 scripts total
```

All these bypassed ungoogled-chromium's patch system, causing:
- Modified source tree
- Patch conflicts (safe_browsing error)
- Can't update ungoogled-chromium

### After Cleanup
```bash
# Clear - two commands
./build/build.sh      # Full build (wraps ungoogled-chromium)
./build/rebuild.sh    # Incremental rebuild
```

Clean approach:
- ungoogled-chromium manages source
- Patches applied via patch system
- No source tree modifications
- Can update ungoogled-chromium anytime

---

## How To Use

### Full Build (First Time)

```bash
./build/build.sh
```

This:
1. Calls `ungoogled-chromium/build.sh`
2. Applies ~150 ungoogled-chromium patches
3. Applies our patches from `/patches/series`
4. Builds browser (2-4 hours)
5. Output: `ungoogled-chromium/build/src/out/Default/Chromium.app`

### Incremental Rebuild (After Changes)

```bash
./build/rebuild.sh
```

This:
1. Only recompiles changed files
2. Much faster (10-30 minutes)
3. Preserves patch state

### Backup/Restore

```bash
# Backup current build
./build/backup.sh my-label

# Restore a backup
./build/restore.sh my-label

# List backups
./build/restore.sh
```

### Test Browser

```bash
./build/test.sh
```

---

## Next Steps

### 1. Clean Source Tree

The source tree still has manual modifications from our debugging:

```bash
cd ungoogled-chromium/build/src
git checkout .          # Revert all changes
git clean -fd           # Remove untracked files
```

### 2. Test Clean Build

```bash
./build/build.sh -d     # -d = don't re-download source
```

This will apply our patches cleanly via the patch system.

### 3. Verify Everything Works

- [ ] Patches apply without conflicts
- [ ] Build completes successfully
- [ ] Browser runs correctly
- [ ] Can apply branding
- [ ] Can create backups

---

## What We Learned

### The Root Cause

We were trying to build Chromium directly, bypassing ungoogled-chromium's patch system. This is the WRONG approach.

**Wrong:**
```bash
# Modify source directly
vim ungoogled-chromium/build/src/build/config/compiler/BUILD.gn
# Then build
gn gen out/Default
ninja -C out/Default chrome
```

**Right:**
```bash
# Create patch
echo "disable-rust-version-check.patch" >> patches/series
# Let build.sh apply it
./build/build.sh
```

### The Lesson

Like Brave and Edge:
- **NEVER** modify source tree directly
- **ALWAYS** use patch system
- Let upstream tool manage source

This prevents:
- Patch conflicts
- Broken source tree
- Can't update upstream
- Hours of debugging

---

## Comparison

### Brave Browser Approach
```
brave-browser/
├── chromium/              # Submodule (never modified)
├── patches/               # Brave patches
└── build/                 # Build wrapper
```

### Microsoft Edge Approach
```
edge/
├── chromium/              # Upstream (never modified)
├── edge_patches/          # Edge patches
└── build/                 # Build wrapper
```

### Base Chrome Approach (Now)
```
base-core/
├── ungoogled-chromium/    # Upstream (never modified)
├── patches/               # Base patches
└── build/                 # Build wrapper
```

**All three use the same pattern:**
1. Upstream code is read-only
2. Changes via patch system
3. Build wrapper orchestrates everything

---

## Files Deleted

### /scripts/ (9 files)
- 1_clone_source.sh
- 2_download_dependencies.sh
- 3_apply_branding.sh
- 4_apply_strings.sh
- 5_build_full.sh
- 5_configure_build.sh
- 6_build_incremental.sh
- 7_apply_strings_and_build.sh
- backup_build.sh (moved to build/)
- restore_build.sh (moved to build/)

### /run/ (16 files)
- 1_update_chromium.sh
- 2_build_binaries.sh
- 2a_build_with_python314_fix.sh
- 2b_build_force_python311.sh
- 2c_build_smart.sh
- 3_check_build_status.sh
- 3_smart_build.sh
- 3b_build_latest_depot_tools.sh
- 4_build_with_python313.sh
- 4_stop_build.sh
- 5_build_macos.sh
- 5_clean_build.sh
- 6_rebuild_only.sh
- 6_setup_python.sh
- check_status.sh
- menu.sh
- test_browser.sh (moved to build/)

### /tools/script/ (3 files)
- build.sh
- retrieve_and_unpack_resource.sh
- sign_and_package_app.sh

**Total Deleted: 27 scripts that broke things**

---

## The Golden Rule

**NEVER modify files in `ungoogled-chromium/build/src/` directly!**

Instead:
1. Create patch file
2. Add to `patches/series`
3. Run `./build/build.sh`
4. Let ungoogled-chromium apply it

This is how Brave, Edge, and all Chromium forks work.

---

Generated: 2025-11-08
