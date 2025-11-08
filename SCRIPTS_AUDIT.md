# Scripts Audit - base-core Repository

**Date:** 2025-11-08
**Status:** Complete analysis of all shell scripts in the base-core repository

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Scripts by Directory](#scripts-by-directory)
3. [Duplicate Scripts](#duplicate-scripts)
4. [Script Status Analysis](#script-status-analysis)
5. [Recommendations](#recommendations)
6. [Cleanup Actions](#cleanup-actions)

---

## Executive Summary

**Total Scripts Analyzed:** 49 custom scripts
**Duplicates Found:** 6 exact duplicates
**Deprecated Scripts:** ~15 scripts (Python version workarounds)
**Active Working Scripts:** ~25 scripts

### Key Findings:

1. **Major Duplication:** `build.sh`, `retrieve_and_unpack_resource.sh`, and `sign_and_package_app.sh` exist in BOTH `tools/script/` and `ungoogled-chromium/` directories with nearly identical code.

2. **Python Version Chaos:** Multiple scripts trying different Python version workarounds (3.11, 3.13, 3.14) - evidence of build struggles. Most are now deprecated as the project settled on Python 3.13.

3. **Two Build Workflows:**
   - `scripts/` directory: Sequential numbered workflow (1-7)
   - `run/` directory: Menu-driven interactive system with multiple experimental approaches

4. **Working Core:** Only a handful of scripts are actually needed:
   - `run/5_build_macos.sh` (primary build script)
   - `scripts/` workflow (clean sequential process)
   - Branding scripts in `features/branding/`

---

## Scripts by Directory

### `/scripts/` - Sequential Build Workflow (GOOD)

**Purpose:** Clean, numbered workflow for building Base Dev browser from scratch

| Script | Purpose | Status | Dependencies |
|--------|---------|--------|--------------|
| `1_clone_source.sh` | Clone Chromium source | Working | ungoogled-chromium/retrieve_and_unpack_resource.sh |
| `2_download_dependencies.sh` | Download build dependencies | Working | ungoogled-chromium utils |
| `3_apply_branding.sh` | Apply Base Dev branding to BRANDING file | Working | features/branding/config.sh |
| `4_apply_strings.sh` | Replace "Chromium" with "Base Dev" in 8 string files (352 replacements) | Working | features/branding/config.sh |
| `5_build_full.sh` | Full build from scratch (2-4 hours) | Working | Python 3.13, GN, Ninja |
| `5_configure_build.sh` | Configure build without building | Working | Python 3.13, GN |
| `6_build_incremental.sh` | Incremental rebuild (10-30 min) | Working | Existing build |
| `7_apply_strings_and_build.sh` | Wrapper: runs 4 + 6 | Working | Scripts 4 & 6 |
| `backup_build.sh` | Backup built .app with label | Working | Built binary |
| `restore_build.sh` | Restore from backup | Working | Backup exists |

**Assessment:** Clean, well-documented workflow. These are the BEST scripts to use.

---

### `/run/` - Experimental Build Scripts (MESSY)

**Purpose:** Various build attempts, menu system, status checking

#### Working & Useful:

| Script | Purpose | Status | Notes |
|--------|---------|--------|-------|
| `menu.sh` | Interactive colorful menu | Working | Nice UX but references broken scripts |
| `check_status.sh` | Show build status with colors | Working | Very useful for monitoring |
| `test_browser.sh` | Test built browser | Working | Checks ungoogled markers |
| `5_build_macos.sh` | Official ungoogled-chromium build | **PRIMARY** | Best build script, uses Python 3.13 |
| `6_rebuild_only.sh` | Quick rebuild after changes | Working | Useful for branding iterations |
| `5_clean_build.sh` | Clean build files interactively | Working | Good cleanup utility |
| `4_stop_build.sh` | Kill running builds | Working | Simple pkill wrapper |

#### Deprecated (Python Version Workarounds):

| Script | Purpose | Status | Reason Deprecated |
|--------|---------|--------|-------------------|
| `2a_build_with_python314_fix.sh` | Python 3.14 compatibility attempt | Deprecated | 3.14 never worked, using 3.13 now |
| `2b_build_force_python311.sh` | Force Python 3.11 | Deprecated | Moved to 3.13 |
| `2c_build_smart.sh` | Smart build with 3.11 | Deprecated | Duplicate of 3_smart_build.sh |
| `3b_build_latest_depot_tools.sh` | Clone fresh depot_tools | Deprecated | No longer needed |
| `4_build_with_python313.sh` | Build with Python 3.13 | **REPLACED** | Functionality now in 5_build_macos.sh |
| `6_setup_python.sh` | Setup Python 3.11 symlinks | Deprecated | Using 3.13 directly |

#### Still Relevant:

| Script | Purpose | Status | Notes |
|--------|---------|--------|-------|
| `1_update_chromium.sh` | Update ungoogled-chromium version | Working | Git operations on submodule |
| `2_build_binaries.sh` | Build with Python 3.11 wrapper | Deprecated | Old approach |
| `3_smart_build.sh` | Smart incremental build | Working | Good for development |
| `3_check_build_status.sh` | Check build status (simple) | Working | Simpler than check_status.sh |

---

### `/features/branding/` - Branding System (GOOD)

**Purpose:** Apply Base Dev branding to Chromium

| Script | Purpose | Status | Notes |
|--------|---------|--------|-------|
| `apply.sh` | Full branding (BRANDING file, plists, strings) | Working | Comprehensive |
| `apply_instant.sh` | Quick rename .app only | Working | Fast 1-second branding |
| `rollback.sh` | Restore original Chromium branding | Working | Restores .orig backups |
| `workflow_test_strings.sh` | Iterative string testing workflow | Working | Development helper |
| `config.sh` | Branding config (PRODUCT_NAME, BUNDLE_ID) | Config | Source file |

#### Branding Scripts Subdirectory:

| Script | Purpose | Status | Notes |
|--------|---------|--------|-------|
| `scripts/find_chromium_strings.sh` | Find "Chromium" in UI strings | Working | Search utility |
| `scripts/replace_strings.sh` | Smart string replacement (44 patterns) | Working | Core branding logic |
| `scripts/generate_icon.sh` | Generate app icons | Not Found | May be missing |

**Assessment:** Well-organized branding system. `apply.sh` is comprehensive, `apply_instant.sh` is clever for quick tests.

---

### `/tools/` - Build Tools (MIXED)

#### `/tools/script/` - DUPLICATES of ungoogled-chromium scripts:

| Script | Purpose | Status | Duplicate Of |
|--------|---------|--------|--------------|
| `build.sh` | Main build script | Working | ungoogled-chromium/build.sh (EXACT DUPLICATE) |
| `retrieve_and_unpack_resource.sh` | Retrieve Chromium source | Working | ungoogled-chromium/retrieve_and_unpack_resource.sh (EXACT DUPLICATE) |
| `sign_and_package_app.sh` | Code signing & DMG creation | Working | ungoogled-chromium/sign_and_package_app.sh (EXACT DUPLICATE) |

#### `/tools/` root:

| Script | Purpose | Status | Notes |
|--------|---------|--------|-------|
| `fix_depot_tools.sh` | Fix depot_tools Python shebangs | Working | Simple sed script, still needed |

**Assessment:** The `tools/script/` directory should be DELETED. Use the ungoogled-chromium versions directly.

---

### `/ungoogled-chromium/` - Official Scripts (UPSTREAM)

**Purpose:** Official ungoogled-chromium-macos build scripts

| Script | Purpose | Status | Notes |
|--------|---------|--------|-------|
| `build.sh` | Official build script | Working | Primary build method |
| `retrieve_and_unpack_resource.sh` | Get Chromium source & deps | Working | Handles clone/download |
| `sign_and_package_app.sh` | Code signing & notarization | Working | Requires Apple Developer account |

**Additional ungoogled-chromium devutils:**
- `devutils/check_patch_files.sh` - Validate patches
- `devutils/update_patches.sh` - Update patch series
- `devutils/set_quilt_vars.sh` - Set quilt environment

**Assessment:** These are the canonical scripts. Keep them, delete the duplicates in `tools/script/`.

---

## Duplicate Scripts

### Exact Duplicates (DELETE 3):

1. **tools/script/build.sh** = ungoogled-chromium/build.sh
   - ACTION: Delete `tools/script/build.sh`
   - USE: `ungoogled-chromium/build.sh`

2. **tools/script/retrieve_and_unpack_resource.sh** = ungoogled-chromium/retrieve_and_unpack_resource.sh
   - ACTION: Delete `tools/script/retrieve_and_unpack_resource.sh`
   - USE: `ungoogled-chromium/retrieve_and_unpack_resource.sh`

3. **tools/script/sign_and_package_app.sh** = ungoogled-chromium/sign_and_package_app.sh
   - ACTION: Delete `tools/script/sign_and_package_app.sh`
   - USE: `ungoogled-chromium/sign_and_package_app.sh`

### Functional Duplicates (CONSOLIDATE 2):

4. **run/2c_build_smart.sh** ~ run/3_smart_build.sh
   - Both do smart incremental builds with Python 3.11
   - ACTION: Delete `2c_build_smart.sh`, keep `3_smart_build.sh`

5. **run/check_status.sh** vs run/3_check_build_status.sh
   - `check_status.sh` is newer, colorful, better
   - ACTION: Delete `3_check_build_status.sh`

6. **scripts/5_build_full.sh** vs scripts/5_configure_build.sh
   - Very similar, 5_build_full.sh includes build step
   - ACTION: Keep both (different purposes)

---

## Script Status Analysis

### Working & Recommended (10 scripts):

1. **scripts/1_clone_source.sh** - Clean source clone
2. **scripts/2_download_dependencies.sh** - Download deps
3. **scripts/3_apply_branding.sh** - BRANDING file
4. **scripts/4_apply_strings.sh** - String replacements
5. **scripts/6_build_incremental.sh** - Fast rebuilds
6. **run/5_build_macos.sh** - PRIMARY BUILD METHOD
7. **features/branding/apply.sh** - Full branding
8. **features/branding/apply_instant.sh** - Quick .app rename
9. **run/check_status.sh** - Status monitoring
10. **run/6_rebuild_only.sh** - Quick recompile

### Deprecated / Remove (15 scripts):

1. run/2a_build_with_python314_fix.sh - Python 3.14 never worked
2. run/2b_build_force_python311.sh - Old Python version
3. run/2c_build_smart.sh - Duplicate of 3_smart_build.sh
4. run/2_build_binaries.sh - Old Python wrapper approach
5. run/3b_build_latest_depot_tools.sh - Not needed
6. run/3_check_build_status.sh - Replaced by check_status.sh
7. run/4_build_with_python313.sh - Logic moved to 5_build_macos.sh
8. run/6_setup_python.sh - Direct Python 3.13 use now
9. tools/script/build.sh - DUPLICATE
10. tools/script/retrieve_and_unpack_resource.sh - DUPLICATE
11. tools/script/sign_and_package_app.sh - DUPLICATE
12. scripts/5_build_full.sh - Use run/5_build_macos.sh instead
13. scripts/5_configure_build.sh - Use run/5_build_macos.sh instead
14. scripts/7_apply_strings_and_build.sh - Manual workflow better
15. run/menu.sh - References broken scripts

### Keep for Development (5 scripts):

1. run/3_smart_build.sh - Good for dev iterations
2. run/1_update_chromium.sh - Version updates
3. features/branding/workflow_test_strings.sh - Testing helper
4. features/branding/scripts/find_chromium_strings.sh - Search utility
5. tools/fix_depot_tools.sh - Still needed for compatibility

---

## Recommendations

### Immediate Actions:

1. **Delete 3 Exact Duplicates:**
   ```bash
   rm tools/script/build.sh
   rm tools/script/retrieve_and_unpack_resource.sh
   rm tools/script/sign_and_package_app.sh
   ```

2. **Delete 12 Deprecated Scripts:**
   ```bash
   rm run/2a_build_with_python314_fix.sh
   rm run/2b_build_force_python311.sh
   rm run/2c_build_smart.sh
   rm run/2_build_binaries.sh
   rm run/3b_build_latest_depot_tools.sh
   rm run/3_check_build_status.sh
   rm run/4_build_with_python313.sh
   rm run/6_setup_python.sh
   rm scripts/5_build_full.sh
   rm scripts/5_configure_build.sh
   rm scripts/7_apply_strings_and_build.sh
   rm run/menu.sh
   ```

3. **Update Documentation:**
   - Create `SCRIPTS_GUIDE.md` documenting the recommended workflow
   - Update README to point to the correct scripts

### Recommended Build Workflow:

**For First-Time Build:**
```bash
# Method 1: Sequential workflow (most explicit)
./scripts/1_clone_source.sh
./scripts/2_download_dependencies.sh
./scripts/3_apply_branding.sh
./scripts/4_apply_strings.sh
./run/5_build_macos.sh

# Method 2: All-in-one (fastest)
./run/5_build_macos.sh  # Handles everything
./features/branding/apply.sh  # Then apply branding
./run/6_rebuild_only.sh  # Quick rebuild with branding
```

**For Incremental Development:**
```bash
# After branding changes:
./features/branding/apply_instant.sh  # 1 second
./run/6_rebuild_only.sh  # 10-30 min

# Or full branding rebuild:
./features/branding/apply.sh
./run/6_rebuild_only.sh
```

**For Updates:**
```bash
./run/1_update_chromium.sh  # Update Chromium version
./run/5_build_macos.sh  # Rebuild
```

### Directory Structure Cleanup:

**KEEP:**
- scripts/ (sequential workflow - good for documentation)
- run/ (working scripts only: 1, 3, 5, 6, check_status, test_browser, clean, stop)
- features/branding/ (all scripts - working well)
- tools/fix_depot_tools.sh (still needed)
- ungoogled-chromium/*.sh (official upstream)

**DELETE:**
- tools/script/ (entire directory - all duplicates)
- run/2*.sh (all Python workarounds)
- run/3b*.sh, run/4*.sh, run/6_setup*.sh (deprecated)
- scripts/5_*.sh, scripts/7_*.sh (superseded)

---

## Cleanup Actions

### Script Removal Plan:

```bash
# Phase 1: Remove exact duplicates
rm -rf tools/script/

# Phase 2: Remove Python version experiments
rm run/2a_build_with_python314_fix.sh
rm run/2b_build_force_python311.sh
rm run/2c_build_smart.sh
rm run/2_build_binaries.sh
rm run/3b_build_latest_depot_tools.sh
rm run/4_build_with_python313.sh
rm run/6_setup_python.sh

# Phase 3: Remove old build scripts
rm scripts/5_build_full.sh
rm scripts/5_configure_build.sh
rm scripts/7_apply_strings_and_build.sh

# Phase 4: Remove outdated utilities
rm run/3_check_build_status.sh
rm run/menu.sh

# After cleanup, update scripts/ README
echo "Updated workflow uses run/5_build_macos.sh" >> scripts/README.md
```

### Final Script Count:

**Before:** 49 scripts
**After:** 20 scripts (59% reduction)

**Remaining Scripts:**
- scripts/: 6 (clone, download, branding x2, incremental build, backup/restore)
- run/: 7 (update, smart build, build macos, rebuild, status, test, clean, stop)
- features/branding/: 5 (apply, instant, rollback, workflow, config + 2 subscripts)
- tools/: 1 (fix_depot_tools.sh)
- ungoogled-chromium/: 3 (build, retrieve, sign - official)

---

## Dependencies Summary

### System Requirements:
- Python 3.13 (settled on this after 3.11/3.14 experiments)
- Homebrew (for dependencies)
- Xcode Command Line Tools
- GNU coreutils (greadlink)
- Node.js
- Ninja
- Git

### Script Dependencies:
- All build scripts depend on: Python 3.13, GN, Ninja
- Branding scripts depend on: features/branding/config.sh
- Build scripts call: ungoogled-chromium/utils/*.py

---

## Notes

### Python Version Evolution:
The repository shows evidence of struggling with Python compatibility:
1. Initially used Python 3.11 (2b, 2_build_binaries)
2. Tried Python 3.14 compatibility fixes (2a)
3. Settled on Python 3.13 (4, 5_build_macos)

The solution: Python 3.13 is the maximum version depot_tools supports (as of 2025).

### Build Script Evolution:
1. **Generation 1:** tools/script/build.sh (copied from ungoogled)
2. **Generation 2:** run/2*.sh, run/3*.sh (Python experiments)
3. **Generation 3:** run/4_build_with_python313.sh (working but verbose)
4. **Generation 4:** run/5_build_macos.sh (current best - clean, tested)

### Branding Approach:
Two-phase branding works well:
- Phase 1: Build vanilla Chromium (run/5_build_macos.sh)
- Phase 2: Apply branding + quick rebuild (apply.sh + rebuild_only.sh)

This is faster than trying to brand before the full build.

---

**End of Audit**
