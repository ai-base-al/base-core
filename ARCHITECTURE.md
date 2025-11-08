# Base Chrome Architecture

**Philosophy: Never Break the Source Tree**

Like Brave and Edge, we build on top of Chromium without modifying the base source tree directly.

---

## Directory Structure

```
base-core/
├── ungoogled-chromium/          # UPSTREAM: ungoogled-chromium-macos (DO NOT MODIFY)
│   ├── build.sh                 # Main build entry point
│   ├── patches/                 # ungoogled-chromium patches
│   └── build/src/               # Chromium source (managed by build.sh)
│
├── patches/                     # BASE: Our custom patches only
│   ├── series                   # Patch order (applied by ungoogled-chromium/build.sh)
│   └── ungoogled-chromium/      # Our patches
│       └── disable-rust-version-check.patch
│
├── features/                    # BASE: Feature modules (branding, etc.)
│   └── branding/
│       ├── patches/             # Branding-specific patches
│       ├── resources/           # Icons, strings, assets
│       └── scripts/             # Post-build branding tools
│
├── build/                       # BASE: Build utilities
│   ├── build.sh                 # Main Base Chrome build script (wraps ungoogled)
│   └── download_cache/          # Shared dependency cache
│
└── binaries/                    # OUTPUT: Built browsers
    ├── Base Dev.app
    └── backups/
```

---

## The Golden Rule

**NEVER modify files in `ungoogled-chromium/build/src/` directly!**

### Why?
- ungoogled-chromium applies ~150 patches to a clean source tree
- Direct modifications cause patch conflicts
- Breaks incremental builds
- Same reason Brave/Edge don't modify Chromium source directly

### Instead:
1. Create a patch file in `/patches/ungoogled-chromium/`
2. Add it to `/patches/series`
3. Let `ungoogled-chromium/build.sh` apply it (line 43)

---

## Build Workflow

### 1. Clean Build (First Time)

```bash
./build/build.sh
```

This script:
1. Calls `ungoogled-chromium/build.sh` (upstream)
2. Applies our patches from `/patches/series`
3. Applies branding from `/features/branding/`
4. Builds browser
5. Post-processes binary (signing, DMG creation)

### 2. Incremental Build (After Changes)

```bash
./build/rebuild.sh
```

This script:
- Only rebuilds changed files
- Preserves patch state
- 10-30 minutes vs 2-4 hours

### 3. Apply Branding (Post-Build)

```bash
./features/branding/apply.sh binaries/Base\ Dev.app
```

This modifies the BUILT binary, not source:
- Renames app bundle
- Updates Info.plist
- Replaces icons
- Does NOT require rebuild

---

## What Goes Where

### `/ungoogled-chromium/` - UPSTREAM CODE (Read-Only)
**Source:** https://github.com/ungoogled-software/ungoogled-chromium-macos
**Updates:** `git pull` or submodule update
**Modifications:** NONE - this is upstream code

**Key Files:**
- `build.sh` - Main build script (calls our patches)
- `patches/` - ungoogled-chromium's own patches
- `build/src/` - Chromium source (auto-managed, never edit)

### `/patches/` - OUR PATCHES ONLY
**Purpose:** Chromium source modifications for Base features
**Format:** Unified diff patches
**Applied by:** `ungoogled-chromium/build.sh` line 43

**Current Patches:**
- `disable-rust-version-check.patch` - Allow custom Rust toolchain

**Adding New Patches:**
1. Create patch: `git diff > /patches/ungoogled-chromium/my-feature.patch`
2. Add to `/patches/series`
3. Rebuild: `./build/build.sh`

### `/features/` - FEATURE MODULES
**Purpose:** Modular features that can be enabled/disabled
**Examples:** branding, sync, wallet, extensions

**Structure:**
```
features/branding/
├── patches/           # Source patches specific to branding
├── resources/         # Assets (icons, strings)
│   ├── icons/
│   └── strings/
└── scripts/           # Build-time and post-build scripts
    ├── apply.sh       # Apply branding to built binary
    └── generate.sh    # Generate assets
```

### `/build/` - BUILD UTILITIES
**Purpose:** Our build scripts that orchestrate the process

**Scripts:**
- `build.sh` - Main entry point (wraps ungoogled-chromium)
- `rebuild.sh` - Incremental rebuild
- `clean.sh` - Clean build artifacts

### `/binaries/` - BUILD OUTPUT
**Purpose:** Built browsers ready to run/distribute

**Structure:**
```
binaries/
├── Base Dev.app              # Current build
├── backups/                  # Saved builds
│   └── Base Dev.app.v1.0
└── dmg/                      # Distribution packages
    └── Base-1.0.dmg
```

---

## Scripts to Keep vs Delete

### KEEP (Core Functionality)

**Upstream (ungoogled-chromium):**
- `ungoogled-chromium/build.sh` - Main build
- `ungoogled-chromium/retrieve_and_unpack_resource.sh` - Download deps
- `ungoogled-chromium/sign_and_package_app.sh` - Create DMG

**Ours (Base Chrome):**
- `build/build.sh` - Our main build wrapper
- `build/rebuild.sh` - Incremental rebuild
- `features/branding/apply.sh` - Post-build branding
- `features/branding/scripts/generate_icon.sh` - Asset generation

### DELETE (Experimental/Broken)

**These bypass ungoogled-chromium and break source tree:**
- `scripts/1_clone_source.sh` - Duplicates ungoogled-chromium/build.sh
- `scripts/2_download_dependencies.sh` - Duplicates upstream
- `scripts/3_apply_branding.sh` - Wrong approach (modifies source)
- `scripts/4_apply_strings.sh` - Wrong approach (modifies source)
- `scripts/5_build_full.sh` - Bypasses ungoogled-chromium
- `scripts/5_configure_build.sh` - Bypasses ungoogled-chromium
- `scripts/6_build_incremental.sh` - Bypasses ungoogled-chromium
- `scripts/7_apply_strings_and_build.sh` - Bypasses ungoogled-chromium
- `run/*.sh` - All experimental Python version attempts
- `tools/script/*.sh` - Duplicates of ungoogled-chromium scripts

**Why delete?**
These scripts try to build Chromium directly, bypassing ungoogled-chromium's patch system. This causes:
- Patch conflicts (safe_browsing BUILD.gn error)
- Broken source tree
- Can't use ungoogled-chromium updates
- Same mistakes we just debugged

---

## Correct Build Flow

```
User runs: ./build/build.sh
    ↓
Calls: ungoogled-chromium/build.sh
    ↓
1. Downloads Chromium source
2. Applies ungoogled-chromium patches (~150 patches)
3. Applies OUR patches from /patches/series
4. Configures build (args.gn)
5. Runs ninja build
6. Signs and packages
    ↓
Post-process: ./features/branding/apply.sh
    ↓
Output: binaries/Base Dev.app (ready to run)
```

---

## Comparison: Brave vs Edge vs Base

### Brave Browser
```
brave-browser/
├── chromium/              # Upstream Chromium (submodule)
├── patches/               # Brave-specific patches
├── components/            # Brave features
└── build/                 # Build scripts
```

**Approach:**
- Chromium as submodule (never modified directly)
- Patches applied via patch system
- Features in separate directory

### Microsoft Edge
```
edge/
├── chromium/              # Upstream Chromium
├── edge_patches/          # Edge modifications
├── edge_components/       # Edge features
└── build/                 # Build orchestration
```

**Approach:**
- Chromium as base layer
- Edge features layered on top
- No direct source modifications

### Base Chrome (Us)
```
base-core/
├── ungoogled-chromium/    # Upstream (ungoogled-chromium-macos)
├── patches/               # Base patches
├── features/              # Base features
└── build/                 # Build orchestration
```

**Approach:**
- ungoogled-chromium as base (gives us privacy patches)
- Our patches layered on top
- Features in modules
- Build scripts wrap upstream

**Key Difference:**
We use ungoogled-chromium instead of vanilla Chromium, giving us:
- Google service removal (already patched)
- Privacy enhancements (already patched)
- Smaller patch surface (we only patch what ungoogled-chromium doesn't)

---

## Migration Plan

### Phase 1: Clean Up (Now)
1. Create `/build/build.sh` (wrapper for ungoogled-chromium/build.sh)
2. Create `/build/rebuild.sh` (incremental builds)
3. Delete all scripts in `/scripts/` and `/run/`
4. Move working scripts to `/build/`

### Phase 2: Fix Patches (Now)
1. Verify `/patches/series` is correct
2. Test that patches apply cleanly
3. Remove any manual modifications to source

### Phase 3: Test Build (Now)
1. Clean source: `rm -rf ungoogled-chromium/build/src/out`
2. Full build: `./build/build.sh`
3. Verify patches apply correctly
4. Verify browser builds

### Phase 4: Feature Modules (Next)
1. Move branding to `/features/branding/`
2. Create module system for features
3. Document feature API

---

## Common Tasks

### Add a New Feature Patch

```bash
# 1. Make changes in ungoogled-chromium/build/src/
cd ungoogled-chromium/build/src
# ... edit files ...

# 2. Create patch
git diff > /Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/my-feature.patch

# 3. Add to series
echo "ungoogled-chromium/my-feature.patch" >> /Volumes/External/BaseChrome/base-core/patches/series

# 4. Revert source changes (let patch system apply them)
git checkout .

# 5. Rebuild (patch will be applied automatically)
cd /Volumes/External/BaseChrome/base-core
./build/build.sh -d  # -d = don't re-download source
```

### Update Ungoogled-Chromium

```bash
cd ungoogled-chromium
git pull origin master
cd ..
./build/build.sh  # Rebuild with new ungoogled-chromium version
```

### Apply Branding to Existing Binary

```bash
# Instant branding (no rebuild needed)
./features/branding/apply.sh "binaries/Base Dev.app"

# This modifies:
# - App name
# - Bundle ID
# - Icons
# - Info.plist

# Does NOT modify:
# - Internal strings (requires rebuild)
# - Code signatures (requires re-sign)
```

### Restore Clean Source

```bash
cd ungoogled-chromium/build/src
git checkout .  # Revert all changes
git clean -fd   # Remove untracked files
```

---

## Key Principles

1. **Separation of Concerns**
   - Upstream code: ungoogled-chromium
   - Our patches: /patches/
   - Our features: /features/
   - Build tools: /build/

2. **Patch-Based Development**
   - All source changes via patches
   - Never edit source directly
   - Patches versioned in git

3. **Modular Features**
   - Features can be enabled/disabled
   - Each feature is self-contained
   - Clear feature boundaries

4. **Upstream Compatibility**
   - Can update ungoogled-chromium anytime
   - Our patches reapply cleanly
   - No merge conflicts

5. **Build Reproducibility**
   - Same inputs = same output
   - Clean build is always possible
   - No hidden state in source tree

---

## Questions?

**Q: Why not fork Chromium directly like Brave?**
A: ungoogled-chromium already removes Google services. We get those patches for free. Less maintenance.

**Q: Can we modify source during development?**
A: Yes, but create a patch before committing. Never commit direct source modifications.

**Q: What if ungoogled-chromium patch conflicts with ours?**
A: Fix our patch. Upstream (ungoogled-chromium) has priority. We layer on top.

**Q: How do we add Base-specific features?**
A: Create patches for source changes, modules for features. See `/features/branding/` example.

---

Generated: 2025-11-08
