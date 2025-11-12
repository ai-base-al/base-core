# Base Browser Build Scripts

All build scripts are in `base-core/scripts/`. Never run scripts directly from `ungoogled-chromium/`.

## Daily Development Workflow

**For incremental builds** (10-30 minutes):
```bash
cd /Volumes/External/BaseChrome/base-core
./scripts/build_incremental.sh
```

This script:
- Builds only changed files
- Auto-backs up after successful build
- Never clones source code
- Safe to run multiple times

## Script Reference

### Regular Use
- `build_incremental.sh` - Incremental build (use this daily)
- `backup_build.sh` - Manual backup of build artifacts
- `restore_build.sh` - Restore from backup

### Setup & Patches
- `init.sh` - **FIRST TIME ONLY** - Full setup with source clone (2-4 hours)
  - **HUMAN ONLY** - Should never be run by LLMs/agents
  - Requires 2 confirmations (y/N + typing "CONFIRM")
  - Calls dangerous ungoogled-chromium/build.sh
- `apply_base.sh` - Apply Base patches to source
- `apply_baseone_branding.sh` - Apply branding patches

### Utilities
- `monitor_build.sh` - Monitor long-running builds
- `keep_disk_active.sh` - Keep external disk active
- `release.sh` - Create release DMG

## Important Rules

1. **NEVER** run `ungoogled-chromium/build.sh` directly
   - **REMOVED** for safety - it clones source code (dangerous - loses your work)
   - Reference copy saved at: `scripts/chromium/build.sh.reference`
   - The init.sh script now implements chromium build steps directly (safe, modular)

2. **ALWAYS** use scripts from `base-core/scripts/`
   - One script, one job principle
   - Safe and tested
   - Follows project conventions
   - All dangerous operations require confirmations

3. **NEVER** modify source directly
   - Always create patches
   - Put patches in `patches/`
   - Add to `patches/series`

4. **ungoogled-chromium/ directory is PRISTINE**
   - Contains only original ungoogled-chromium-macos repository files
   - NO custom scripts allowed
   - All Base customization in `base-core/` only

## Workflow Example

```bash
# Day 1: First time setup (once only)
./scripts/init.sh              # 2-4 hours

# Day 2+: Daily development
# 1. Make changes in ungoogled-chromium/build/src/
# 2. Build
./scripts/build_incremental.sh  # 10-30 minutes
# 3. Test the app
open /Volumes/External/BaseChrome/ungoogled-chromium/build/src/out/Default/BaseOne.app
# 4. If works → commit
git add patches/
git commit -m "Add feature X"

# If something breaks → restore
./scripts/restore_build.sh
git revert HEAD
```

## Build Artifacts Location

```
ungoogled-chromium/build/src/
└── out/Default/
    ├── BaseOne.app          # Built browser
    ├── args.gn              # Build config
    └── obj/                 # Object files (~10-15GB)
```

## Backup System

Automatic backup after every successful build:
- Location: `base-core/backups/latest/`
- Contents: Full `out/Default/` directory
- Size: ~5-8GB compressed
- Only keeps latest (no versioning)

To restore:
```bash
./scripts/restore_build.sh
```

## Emergency Recovery

If build breaks:
```bash
# Restore last working build
./scripts/restore_build.sh

# Revert code changes
git revert HEAD

# Rebuild
./scripts/build_incremental.sh
```

## Notes

- `init.sh` is for first-time setup only
- `build_incremental.sh` is your daily driver
- Source code stays in `ungoogled-chromium/build/src/` permanently
- Never run `rm -rf build/src` unless you want to start over
