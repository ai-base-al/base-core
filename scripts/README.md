# BaseOne Build Scripts

Organized collection of build and release automation scripts.

## Core Workflow Scripts

These scripts form the primary build workflow. Use these for day-to-day development:

### apply_base.sh
**Purpose**: Apply all patches and branding to Chromium source

**Usage**:
```bash
./scripts/apply_base.sh
```

**What it does**:
1. Applies custom patches from `patches/series`
2. Applies BaseOne branding (strings + icons)
3. Shows summary of modified files

**When to use**: After resetting source or before building

### build_incremental.sh
**Purpose**: Incremental build (rebuilds only changed files)

**Usage**:
```bash
./scripts/build_incremental.sh
```

**Time**: 10-30 minutes (vs 2-4 hours for full build)

**When to use**: After making code changes, after applying patches/branding

### release.sh
**Purpose**: Create complete release with DMG, git tag, and GitHub release

**Usage**:
```bash
./scripts/release.sh -v 0.1.0 -c "Codename"
```

**Flags**:
- `-v, --version` - Version number (required, e.g., 0.1.0)
- `-c, --codename` - Release codename (e.g., "Inception")
- `-s, --skip-build` - Skip building (use existing binary)
- `-n, --no-tag` - Don't create git tag
- `-g, --no-github` - Don't create GitHub release
- `--no-signing` - Skip code signing (testing only)
- `--no-notarize` - Skip notarization (faster, testing only)

**What it does**:
1. Builds BaseOne (or uses existing binary)
2. Signs application with Developer ID
3. Notarizes with Apple
4. Creates DMG package
5. Creates git tag
6. Publishes GitHub release with DMG

**When to use**: When ready to create an official release

## Utility Scripts

### apply_baseone_branding.sh
**Purpose**: Apply BaseOne branding (strings + icons)

**Usage**:
```bash
./scripts/apply_baseone_branding.sh
```

**Called by**: `apply_base.sh` (don't usually call directly)

**What it does**:
1. Replaces "Chromium" with "BaseOne" in UI strings
2. Updates copyright to BaseCode LLC
3. Copies BaseOne icons (7 PNG sizes + app.icns)
4. Copies theme logos

## Deprecated Scripts

The following scripts are old/redundant and should not be used:

### build.sh
**Status**: DEPRECATED - Use `build_incremental.sh` instead

### build_continue.sh
**Status**: DEPRECATED - Use `build_incremental.sh` instead

### clone.sh
**Status**: DEPRECATED - Use ungoogled-chromium's build system

### patch.sh
**Status**: DEPRECATED - Use `apply_base.sh` instead

### sync.sh
**Status**: DEPRECATED - Use `apply_base.sh` instead

### rename_chromium_binaries.sh
**Status**: DEPRECATED - Branding handles this

### post_build.sh
**Status**: DEPRECATED - No longer needed

### init.sh
**Status**: REVIEW NEEDED - May be useful for initial setup

### keep_disk_active.sh
**Status**: UTILITY - Keep for long builds if needed

### monitor_build.sh
**Status**: UTILITY - Keep for monitoring long builds

## Quick Reference

| Task | Command |
|------|---------|
| Apply patches and branding | `./scripts/apply_base.sh` |
| Build (incremental) | `./scripts/build_incremental.sh` |
| Test the app | `open ungoogled-chromium/build/src/out/Default/BaseOne.app` |
| Create release | `./scripts/release.sh -v 0.1.0 -c "Codename"` |
| Reset source | `cd ungoogled-chromium/build/src && git reset --hard HEAD && git clean -fd` |

## Full Development Cycle

```bash
# 1. Reset source (if needed)
cd /Volumes/External/BaseChrome/ungoogled-chromium/build/src
git reset --hard HEAD
git clean -fd

# 2. Apply patches and branding
cd /Volumes/External/BaseChrome/base-core
./scripts/apply_base.sh

# 3. Build
./scripts/build_incremental.sh

# 4. Test
open /Volumes/External/BaseChrome/ungoogled-chromium/build/src/out/Default/BaseOne.app

# 5. Create release (when ready)
./scripts/release.sh -v 0.1.0 -c "Inception"
```

## Environment Variables

Scripts use these paths (defined internally):

- `SCRIPT_DIR` - Directory containing the script
- `BASE_DIR` - base-core repository root
- `SRC_DIR` - Chromium source: `/Volumes/External/BaseChrome/ungoogled-chromium/build/src`
- `OUT_DIR` - Build output: `$SRC_DIR/out/Default`
- `BINARIES_DIR` - Binary storage: `/Volumes/External/BaseChrome/baseone-binaries`
- `RELEASES_DIR` - Release DMGs: `/Volumes/External/BaseChrome/baseone-binaries/releases`

## Script Consolidation Plan

To clean up deprecated scripts:

```bash
cd /Volumes/External/BaseChrome/base-core/scripts

# Move deprecated scripts to archive
mkdir -p _deprecated
mv build.sh _deprecated/
mv build_continue.sh _deprecated/
mv clone.sh _deprecated/
mv patch.sh _deprecated/
mv sync.sh _deprecated/
mv rename_chromium_binaries.sh _deprecated/
mv post_build.sh _deprecated/

# Review and decide on these
# - init.sh (may be useful for first-time setup)
# - keep_disk_active.sh (utility)
# - monitor_build.sh (utility)
```

## Adding New Scripts

When creating new scripts:

1. **Use consistent naming**: `verb_noun.sh` (e.g., `apply_base.sh`, `build_incremental.sh`)
2. **Include header comment**:
   ```bash
   #!/bin/bash
   # Script Name and Purpose
   # Company: BaseCode LLC
   # Product: BaseOne
   ```
3. **Use common functions**:
   ```bash
   log()   { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"; }
   warn()  { echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"; }
   error() { echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"; exit 1; }
   ```
4. **Make executable**: `chmod +x scripts/new_script.sh`
5. **Document here**: Add to appropriate section in this README
6. **Test thoroughly**: Test on clean source before committing

## Support

For issues or questions:
- Check docs/BRANDING.md for branding details
- Check patches/README.md for patch system details
- Check MAP.md for overall repository structure
