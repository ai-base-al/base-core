# Quick Start Guide

Get up and running with Base Core development in a few steps.

## Prerequisites

Before you begin, install these tools:

```bash
# Install depot_tools (Chromium build tools)
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:/path/to/depot_tools"

# Install build dependencies (Linux)
sudo apt-get install build-essential python3 nodejs npm ninja-build

# Install build dependencies (macOS)
xcode-select --install
brew install python3 node ninja
```

## Setup (First Time)

```bash
# 1. Clone base-core
git clone https://github.com/ai-base-al/base-core.git
cd base-core

# 2. Install npm dependencies
npm install

# 3. Initialize and download Chromium (this takes a while and downloads several GB)
npm run init

# 4. Sync dependencies and apply patches
npm run sync
```

## Building

```bash
# Release build (recommended for testing)
npm run build:Release

# Debug build (for development with symbols)
npm run build:Debug

# Generate build files with custom args
npm run gn
```

## Running the Browser

After building:

```bash
# Run the browser (adjust path based on OS)
../out/Release/chrome

# Or with additional flags
../out/Release/chrome --user-data-dir=/tmp/base-test
```

## Development Workflow

### Making Changes

**Option 1: Chromium Source Overrides (for substantial changes)**
```bash
# Place your modified files in chromium_src/ matching Chromium's structure
mkdir -p chromium_src/chrome/browser/ui
cp ../src/chrome/browser/ui/toolbar.cc chromium_src/chrome/browser/ui/
# Edit chromium_src/chrome/browser/ui/toolbar.cc
```

**Option 2: Patches (for small changes)**
```bash
# Make changes in the Chromium source
cd ../src
# Edit files...
git add -A
git diff --staged > ../base/patches/my-feature.patch

# Apply patches
cd ../base
npm run apply_patches
```

### Building & Testing

```bash
# Incremental build (faster after initial build)
npm run build

# Run tests
npm test

# Run specific test suite
ninja -C ../out/Release base_unittests
../out/Release/base_unittests --gtest_filter="MyTest.*"
```

### Updating

```bash
# Sync to latest changes
git pull
npm run sync
npm run build
```

## Common Commands

| Command | Description |
|---------|-------------|
| `npm run init` | First-time setup, downloads Chromium |
| `npm run sync` | Sync dependencies and apply patches |
| `npm run build` | Build the browser (Release) |
| `npm run build:Debug` | Build debug version |
| `npm run apply_patches` | Apply patches only |
| `npm test` | Run all tests |
| `npm run lint` | Check code style |
| `npm run format` | Format code |

## Troubleshooting

### depot_tools not found
```bash
export PATH="$PATH:/path/to/depot_tools"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

### Build fails with "ninja not found"
```bash
# Linux
sudo apt-get install ninja-build

# macOS
brew install ninja
```

### Patches fail to apply
```bash
# Reset patches and try again
python3 script/apply_patches.py --reset
npm run sync

# If still failing, manually resolve conflicts in ../src
```

### Out of disk space
Chromium builds require significant disk space:
- Source: ~30 GB
- Build output: 20-50 GB depending on build type
- Total: ~60-80 GB minimum

### Build is slow
```bash
# Use component build for faster incremental builds
gn gen ../out/Component --args='is_component_build=true'
ninja -C ../out/Component base
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Explore the `components/` directory to add new features
- Review `patches/` and `chromium_src/` for examples

## Getting Help

- Check existing issues on GitHub
- Review Chromium documentation: https://www.chromium.org/developers/
- Consult ungoogled-chromium docs: https://github.com/ungoogled-software/ungoogled-chromium

## Useful Resources

- [Chromium Development Guide](https://www.chromium.org/developers/how-tos/get-the-code/)
- [GN Build Configuration](https://gn.googlesource.com/gn/+/main/docs/)
- [Ninja Build System](https://ninja-build.org/manual.html)
- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium)
