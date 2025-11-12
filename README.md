# BaseOne - Custom Chromium Browser

BaseOne is a custom Chromium-based browser built on ungoogled-chromium, featuring privacy-first defaults and custom development tools.

## Repository Structure

This repository uses a Brave/Edge-style structure where ungoogled-chromium is kept as a separate upstream dependency:

```
/Volumes/External/BaseChrome/
├── ungoogled-chromium/          # Upstream repository (separate)
│   └── build/src/              # Chromium source (stays here permanently!)
└── base-core/                   # This repository
    ├── src -> ../ungoogled-chromium/build/src  # Symlink to source
    ├── patches/                 # BaseOne custom patches
    │   ├── series              # Patch application order
    │   └── *.patch             # Individual patch files
    ├── scripts/                        # Build and development scripts
    │   ├── init.sh                    # Full setup workflow (2-4 hours)
    │   ├── build_incremental.sh       # Incremental build (10-30 min)
    │   ├── apply_baseone_branding.sh  # Apply branding
    │   ├── backup_build.sh            # Backup built browser
    │   └── restore_build.sh           # Restore backed up browser
    ├── tools/                  # Development tools
    ├── branding/              # BaseOne branding assets
    ├── backups/               # Built browser backups
    ├── logs/                  # Build logs
    └── guides/                # Development documentation
```

## Quick Start

### First Time Setup

If you're setting up a new development environment:

```bash
cd base-core
./scripts/init.sh
```

This will:
1. Build ungoogled-chromium from scratch (2-4 hours)
2. Apply BaseOne patches
3. Build the browser with BaseOne customizations

### Daily Development Workflow

For regular feature development (incremental builds):

```bash
# 1. Make your changes to source files in src/
vim src/chrome/browser/ui/...

# 2. Build (only recompiles changed files, 10-30 min)
./scripts/build_incremental.sh

# 3. Run the browser
open "src/out/Default/Base Dev.app"
```

### Update Chromium Version

When updating to a newer ungoogled-chromium version:

```bash
./scripts/sync.sh
```

This will:
1. Backup current build
2. Update ungoogled-chromium
3. Perform full rebuild (2-4 hours)
4. Apply BaseOne patches

## Build Scripts

| Script | Purpose | Time | When to Use |
|--------|---------|------|-------------|
| `init.sh` | Full build workflow | 2-4 hours | First time or complete rebuild |
| `build_incremental.sh` | Incremental build | 10-30 min | Daily development (most common) |

All build scripts automatically log output to `logs/build.log`. Monitor progress:
```bash
tail -f logs/build.log
```

**Important**: Source code stays in `ungoogled-chromium/build/src` permanently. The `src/` directory is just a symlink. This prevents re-cloning on future builds!

## Creating Custom Features

### Using the Sidepanel Generator

The fastest way to add custom features is using the sidepanel generator:

```bash
./tools/sidepanel.sh <PanelName> ["Optional description"]
```

Examples:
```bash
./tools/sidepanel.sh Reading "Clean reading mode"
./tools/sidepanel.sh Notes "Quick note-taking"
./tools/sidepanel.sh Translate "Built-in translation"
```

This automatically:
- Generates all necessary C++, Mojo, HTML, CSS, TypeScript files
- Creates a patch file in `patches/`
- Adds to `patches/series`
- Uses correct `basedev_` naming convention

After generation:
```bash
./scripts/build_incremental.sh  # Build with new feature
```

### Manual Feature Development

For custom features beyond sidepanels:

1. Make changes directly in `src/`
2. Create a patch:
   ```bash
   cd src
   git add .
   git commit -m "Add feature X"
   git format-patch -1 HEAD
   mv 0001-*.patch ../patches/basedev-feature-x.patch
   echo "basedev-feature-x.patch" >> ../patches/series
   ```
3. Build: `./scripts/build_incremental.sh`

## Naming Convention

All custom BaseOne features use the `basedev_` prefix:

- **Patches**: `basedev-{category}-{feature}.patch`
- **Directories**: `basedev_{feature}/`
- **C++ Classes**: `BaseOne{Feature}{Component}`
- **URLs**: `chrome://basedev-{feature}/`

Example: Test sidepanel feature
- Patch: `basedev-sidepanel-test-minimal.patch`
- Button: `BaseOneTestButton`
- Coordinator: `BaseOneTestCoordinator`
- Files: `basedev_test_button.{h,cc}`

See `guides/BASEDEV_NAMING.md` for complete reference.

## Development Guides

Comprehensive guides are available in the `guides/` directory:

- `guides/SIDEPANEL.md` - Creating custom side panels
- `guides/BASEDEV_NAMING.md` - Naming convention reference
- `guides/BRANDING.md` - Branding system documentation

## Directory Details

### `src/` - Symlink to Source

Symlink to `ungoogled-chromium/build/src` for convenience. Source stays in ungoogled-chromium to prevent re-cloning.

Actual source location:
```
ungoogled-chromium/build/src/
├── chrome/              # Chrome browser implementation
├── components/          # Reusable components
├── content/            # Content layer
├── ui/                 # UI framework
└── out/Default/        # Build output
    └── BaseOne.app    # Built browser
```

### `patches/` - BaseOne Patches

Custom patches that add BaseOne features:

```
patches/
├── series                              # Patch order
├── basedev-sidepanel-test-minimal.patch  # Example: test sidepanel
└── ...                                 # Future patches
```

### `backups/` - Browser Backups

Built browser binaries saved for quick restoration:

```bash
backups/
├── Releases/                    # Release builds
│   └── BaseOne.app            # Latest working build
└── ungoogled-chromium_*.dmg    # DMG archives
```

### `tools/` - Development Tools

Automated development tools:

- `sidepanel.sh` - Sidepanel generator
- `sidepanel-minimal.sh` - Minimal sidepanel variant
- `README.md` - Tool documentation

## Build System Architecture

### Why This Structure?

This structure separates concerns:

1. **ungoogled-chromium** (upstream) - Privacy patches, stays separate
2. **base-core** (our repo) - Our custom patches and scripts
3. **src/** (working tree) - Combined result, not committed

Benefits:
- Incremental builds for daily development (10-30 min)
- Full rebuilds only when updating Chromium (monthly)
- Clear separation between upstream and custom code
- Easy to update ungoogled-chromium without conflicts

### Build Flow

```
ungoogled-chromium patches
         ↓
    Chromium source
         ↓
   BaseOne patches (patches/)
         ↓
   Working tree (src/)
         ↓
   Incremental build
         ↓
   BaseOne.app
```

## Common Tasks

### Check What's Modified

```bash
cd src
git status
git diff
```

### Revert Changes

```bash
cd src
git reset --hard HEAD
```

### Update a Patch

```bash
# 1. Make changes in src/
cd src
# ... edit files ...

# 2. Create new patch
git add .
git commit -m "Update feature X"
git format-patch -1 HEAD

# 3. Replace old patch
mv 0001-*.patch ../patches/basedev-feature-x.patch

# 4. Rebuild
cd ..
./scripts/build_incremental.sh
```

### Run Browser with Logging

```bash
cd src
./out/Default/Base\ Dev.app/Contents/MacOS/Base\ Dev \
  --enable-logging=stderr \
  --v=1
```

## Version Information

- Chromium: 142.0.7444.134
- ungoogled-chromium: Based on 142.0.7444.134
- Platform: macOS ARM64 (Apple Silicon)
- Deployment Target: macOS 11.0+

## Repository Not Tracking

These are intentionally not tracked in git (see `.gitignore`):

- `src/` - Symlink to ungoogled-chromium/build/src
- `logs/` - Build logs
- `backups/` - Built browser binaries
- `*.app` - Application bundles

Note: The actual Chromium source (14GB) lives in `ungoogled-chromium/build/src` and is managed by ungoogled-chromium's build system.

## Getting Help

- Check `guides/` for comprehensive documentation
- See `tools/README.md` for tool usage
- Review `patches/` for implementation examples

## Contributing

When adding new features:

1. Use `basedev_` naming convention
2. Create patches in `patches/`
3. Add to `patches/series`
4. Document in feature commit message
5. Test with incremental build

## License

BaseOne includes code from:
- Chromium (BSD-3-Clause)
- ungoogled-chromium (BSD-3-Clause)

See LICENSE for details.
