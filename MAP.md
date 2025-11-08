# Base Chrome Repository Map

Complete directory and file map for the base-core ungoogled-chromium build repository.

## Quick Reference

- **Working Browser**: `binaries/Base Dev.app` (142.0.7444.134)
- **Backup Browser**: `binaries/backups/Base Dev.app.vanilla-142.0.7444.134`
- **Original DMG**: `binaries/ungoogled-chromium_142.0.7444.134-1.1_macos.dmg` (125 MB)
- **Build Scripts**: `scripts/` (main workflow scripts)
- **Source Code**: `ungoogled-chromium/build/src/` (Chromium source, ~15GB when built)
- **Downloaded Dependencies**: `build/download_cache/` (rust, clang, node, etc.)

---

## Root Directory: `/Volumes/External/BaseChrome/base-core/`

### `/binaries/` - Built Applications and Backups
**Purpose**: Contains compiled browser binaries ready to run

- `Base Dev.app` - Current working browser with instant branding applied
  - Bundle ID: al.base.BaseDev
  - Version: 142.0.7444.134
  - Size: ~350 MB
  - Status: Working, instant branding only (no string changes compiled yet)

- `backups/` - Saved builds for restoration
  - `Base Dev.app.vanilla-142.0.7444.134` - Backup of working browser
  - Created by: `scripts/backup_build.sh`
  - Restored by: `scripts/restore_build.sh`

- `ungoogled-chromium_142.0.7444.134-1.1_macos.dmg` - Original DMG (125 MB)
  - Source of current working binaries
  - Created from previous successful build

### `/scripts/` - Main Build Workflow Scripts
**Purpose**: Primary scripts for building and managing the browser

**Configuration & Build:**
- `1_clone_source.sh` - Clone Chromium source code
- `2_download_dependencies.sh` - Download build dependencies
- `3_apply_branding.sh` - Apply Base Dev branding to source
- `4_apply_strings.sh` - Apply 352 string replacements (Chromium → Base Dev)
- `5_configure_build.sh` - Configure build system (creates args.gn)
- `5_build_full.sh` - Full build from scratch (2-4 hours)
- `6_build_incremental.sh` - Incremental build (10-30 minutes)
- `7_apply_strings_and_build.sh` - Combined: apply strings + build

**Backup & Restore:**
- `backup_build.sh` - Save current build with label
- `restore_build.sh` - Restore a saved build

**Recent Updates (Nov 8, 2025):**
- All scripts updated to use Python 3.13
- Automatic depot_tools patching for Python 3.14 compatibility
- See: `SCRIPTS_UPDATED.md`

### `/tools/` - Utility Scripts and Patches
**Purpose**: Additional tools for fixing build issues

- `patch_depot_tools.py` - Fixes Python 3.14 AST compatibility
  - Patches gclient_eval.py for ast.Str → ast.Constant
  - Updates 330 files to use python3.11
  - Applied automatically by build scripts

- `fix_python314.py` - Python 3.14 compatibility fixer
- `fix_depot_tools.sh` - Shell wrapper for depot_tools fixes

- `script/` - Additional build scripts
  - `build/download_cache/` - Build tool cache location

### `/build/download_cache/` - Pre-downloaded Build Dependencies
**Purpose**: Cached toolchains and dependencies to avoid re-downloading

**Contents:**
- `clang+llvm-21.1.0-arm64-apple-darwin21.0.tar.xz` - LLVM/Clang compiler
- `rust-nightly-2025-09-30-aarch64-apple-darwin.tar.xz` - Rust toolchain
- `node-v22.11.0-darwin-arm64.tar.xz` - Node.js runtime
- `google-toolbox-for-mac-v3.0.0.tar.gz` - macOS utilities

**Status**: All extracted to `ungoogled-chromium/build/src/third_party/`

### `/ungoogled-chromium/` - Main Build Directory
**Purpose**: ungoogled-chromium-macos repository and build workspace

**Key Files:**
- `build.sh` - Main ungoogled-chromium build script
- `retrieve_and_unpack_resource.sh` - Download and extract dependencies
- `sign_and_package_app.sh` - Sign and create DMG

**Configuration:**
- `downloads.ini` - Dependency download URLs
- `downloads-arm64.ini` - ARM64-specific downloads
- `downloads-arm64-rustlib.ini` - Rust libraries for ARM64
- `flags.macos.gn` - macOS-specific GN build flags

**Directories:**
- `build/` - Build workspace
  - `build/src/` - Chromium source code (~10GB, ~15GB when built)
  - `build/src/out/Default/` - Build output directory
  - `build/download_cache/` - Symlink to `/build/download_cache/`

- `patches/ungoogled-chromium/` - macOS-specific patches
- `entitlements/` - macOS app entitlements for code signing
- `devutils/` - Development utilities and scripts

### `/ungoogled-chromium-common/` - Shared ungoogled-chromium Resources
**Purpose**: Core ungoogled-chromium patches and utilities (submodule)

**Patches:**
- `patches/core/` - Core privacy patches
  - `bromite/` - Bromite patches (privacy/fingerprinting)
  - `inox-patchset/` - Inox browser patches
  - `iridium-browser/` - Iridium browser patches
  - `ungoogled-chromium/` - Main ungoogled patches

- `patches/extra/` - Optional feature patches
  - Feature flags, UI customizations, etc.

- `patches/upstream-fixes/` - Fixes for build issues

**Utilities:**
- `utils/` - Python utilities
  - `patches.py` - Apply patches to source
  - `domain_substitution.py` - Replace Google domains
  - `downloads.py` - Manage dependency downloads
  - `prune_binaries.py` - Remove proprietary binaries

- `devutils/` - Development tools
  - `update_patches.py` - Update patch series
  - `validate_patches.py` - Validate patch files

**Configuration:**
- `domain_regex.list` - Domains to replace
- `domain_substitution.list` - Files to apply domain substitution
- `pruning.list` - Binaries to remove

### `/config/` - Build Configuration
**Purpose**: Configuration files for build system

Contents TBD (need to explore)

### `/branding/` - Base Dev Branding Assets
**Purpose**: Icons, logos, and branding resources

- `generated_icons/` - Generated icon sets for macOS
- Contains Base Dev logos and product icons

### `/features/branding/` - Feature-specific Branding
**Purpose**: Modular branding patches and resources

- `icons/` - Icon source files
- `patches/` - Branding-related patches
- `scripts/` - Icon generation scripts

### `/patches/` - Custom Patches
**Purpose**: Base-specific patches (separate from ungoogled-chromium)

- `series` - Patch application order
- Custom patches for Base Dev features

### `/entitlements/` - macOS Code Signing Entitlements
**Purpose**: Entitlement files for macOS app signing

Required for distribution on macOS (security permissions, sandboxing, etc.)

### `/run/` - Alternative Build Scripts
**Purpose**: Alternative or experimental build scripts

Contents:
- `5_build_macos.sh` - macOS build script
- `6_rebuild_only.sh` - Rebuild-only script

Status: These may be outdated, use `/scripts/` for primary workflow

### `/logs/` - Build Logs
**Purpose**: Log files from builds

Currently empty or minimal

### `/docs/` - Documentation
**Purpose**: Project documentation

May contain build notes, setup instructions, etc.

---

## Important File Locations

### Source Code Locations (when built)

**Chromium Source:**
```
ungoogled-chromium/build/src/
├── chrome/                    # Chrome browser implementation
├── components/                # Reusable components
├── content/                   # Content layer (rendering, etc.)
├── ui/                        # UI framework
├── third_party/               # Third-party dependencies
│   ├── rust-toolchain/       # Rust compiler (extracted)
│   ├── llvm-build/           # LLVM/Clang (extracted)
│   └── ...
├── build/                     # Build system files
├── tools/                     # Build tools
└── out/Default/              # Build output
    ├── args.gn               # GN build configuration
    ├── Base Dev.app          # Built browser
    └── obj/                  # Object files
```

**String Files Modified (352 replacements):**
```
ungoogled-chromium/build/src/chrome/app/
├── chromium_strings.grd
├── settings_chromium_strings.grdp
├── generated_resources.grd
├── google_chrome_strings.grd
└── ...
```

### Build Toolchain Locations

**Extracted Dependencies:**
```
ungoogled-chromium/build/src/
├── buildtools/mac/gn                                     # GN build tool
├── third_party/rust-toolchain/                          # Rust toolchain
│   ├── VERSION                                          # 15283f6fe95e5b604273d13a428bab5fc0788f5a-1
│   ├── bin/rustc                                        # Rust compiler
│   └── ...
├── third_party/llvm-build/Release+Asserts/             # LLVM/Clang
│   ├── cr_build_revision                                # llvmorg-22-init-8940-g4d4cb757-4
│   ├── bin/clang                                        # Clang compiler
│   └── ...
└── uc_staging/depot_tools/                              # Chromium build tools
    ├── .patched                                         # Marker: Python 3.14 patch applied
    ├── gclient                                          # Dependency manager
    ├── gclient_eval.py                                  # Patched for Python 3.14
    └── ...
```

---

## Workflow Summary

### Initial Build (from previous session)
1. Cloned source → `ungoogled-chromium/build/src/`
2. Downloaded dependencies → `build/download_cache/`
3. Applied patches and built browser
4. Created DMG → `binaries/ungoogled-chromium_142.0.7444.134-1.1_macos.dmg`

### Current State (This Session)
1. Extracted browser from DMG → `binaries/Base Dev.app`
2. Applied instant branding (renamed app, updated Info.plist)
3. Created backup → `binaries/backups/Base Dev.app.vanilla-142.0.7444.134`
4. Applied 352 string replacements to source files
5. Updated all build scripts for Python 3.13 + depot_tools patching
6. **Blocked on**: Rust version checking preventing builds

### Next Steps to Complete Build
1. ~~Fix Rust/LLVM version checking in BUILD.gn~~ BYPASSED (caused new issues)
2. Use ungoogled-chromium's build.sh instead of direct scripts
3. Apply string changes to source
4. Run full build using ungoogled-chromium/build.sh
5. Package into DMG with full Base Dev branding

### Build System Location (per MAP.md)
- ungoogled-chromium build script: `ungoogled-chromium/build.sh`
- Our custom scripts: `scripts/` (currently incompatible with modified source)

---

## Known Issues

### Current Blocker: Safe Browsing BUILD.gn Error
**Issue**: build/config/compiler/BUILD.gn disabled Rust version check, but now hitting safe_browsing BUILD.gn error
**Error**: `Undefined identifier: sources`  at chrome/browser/safe_browsing/BUILD.gn:110
**Cause**: Modified BUILD.gn conflicts with ungoogled-chromium patches
**Location**: `ungoogled-chromium/build/src/build/config/compiler/BUILD.gn:1814-1821`
**Fix Applied**: Commented out Rust version assertion (lines 1814, 1818-1821)
**Status**: BLOCKED - Need to use ungoogled-chromium's build system instead of direct gn/ninja

### Rust Version Checking (BYPASSED)
**Issue**: build/config/compiler/BUILD.gn assertion fails even with correct versions
**Error**: `rustc_revision="15283f6fe95e5b604273d13a428bab5fc0788f5a-1" but update_rust.py expected "15283f6fe95e5b604273d13a428bab5fc0788f5a-1"`
**Cause**: Pattern matching expects format like `*-15283f6fe95e5b604273d13a428bab5fc0788f5a-1-*`
**Solution**: Disabled version check assertion at build/config/compiler/BUILD.gn:1817
**Status**: BYPASSED but caused new issues

### Python 3.14 Compatibility
**Issue**: depot_tools uses deprecated ast.Str
**Solution**: tools/patch_depot_tools.py (applied automatically by build scripts)
**Status**: FIXED

---

## File Sizes Reference

- Chromium source (pre-build): ~10 GB
- Chromium source (post-build): ~15 GB
- Built browser (.app): ~350 MB
- DMG (compressed): ~125 MB
- Download cache: ~2 GB

---

## Version Information

- Chromium: 142.0.7444.134
- ungoogled-chromium: Based on 142.0.7444.134
- Rust: nightly-2025-09-30 (15283f6fe95e5b604273d13a428bab5fc0788f5a-1)
- LLVM: 21.1.0 (llvmorg-22-init-8940-g4d4cb757-4)
- Node.js: 22.11.0
- macOS: ARM64 (Apple Silicon)
- Deployment Target: macOS 11.0+

---

## Quick Commands

**Build:**
```bash
./scripts/5_configure_build.sh    # Configure build
./scripts/6_build_incremental.sh  # Fast build (10-30 min)
./scripts/5_build_full.sh         # Full build (2-4 hours)
```

**Backup/Restore:**
```bash
./scripts/backup_build.sh vanilla-142.0.7444.134  # Save build
./scripts/restore_build.sh vanilla-142.0.7444.134 # Restore build
./scripts/restore_build.sh                        # List backups
```

**Run Browser:**
```bash
open "binaries/Base Dev.app"
open "ungoogled-chromium/build/src/out/Default/Base Dev.app"
```

**Apply String Changes:**
```bash
./scripts/4_apply_strings.sh                    # Just apply strings
./scripts/7_apply_strings_and_build.sh          # Apply + build
```

---

Generated: November 8, 2025
