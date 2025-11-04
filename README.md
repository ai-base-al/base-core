# Base Core

[![Release](https://img.shields.io/github/v/release/ai-base-al/base-core)](https://github.com/ai-base-al/base-core/releases)
[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)

A customized browser based on [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) for macOS, using a brave-core inspired architecture for easy feature development.

## Overview

Base Core extends ungoogled-chromium with custom features while maintaining its privacy-focused philosophy. The repository structure is modeled after brave-core for easier development and maintenance.

## Downloads

[Download the latest release](https://github.com/ai-base-al/base-core/releases/latest) for macOS (supports both Apple Silicon and Intel Macs)

## Quick Start

### Prerequisites

- **macOS 11.0+** (Big Sur or later)
- **Xcode 12+** with Command Line Tools
- **Homebrew** for dependencies

### Setup

```bash
# Install dependencies
brew install python@3 ninja coreutils readline node

# Install Python packages
pip3 install PySocks httplib2

# Install Metal toolchain
xcodebuild -downloadComponent MetalToolchain

# Clone the repository
git clone --recurse-submodules https://github.com/ai-base-al/base-core.git
cd base-core
```

### Building

```bash
# For Apple Silicon Macs (M1/M2/M3)
npm run build

# For Intel Macs
npm run build:x86_64

# Skip re-downloading if you already have the source
npm run build:no-download
```

The build process will:
1. Download Chromium source (~30GB) to `build/src/`
2. Apply ungoogled-chromium patches
3. Apply Base Core patches
4. Build the browser
5. Create a signed `.dmg` in `build/`

## Project Structure

```
base-core/
├── chromium_src/         # Override Chromium source files (our customizations)
├── patches/              # Our custom patches on top of ungoogled-chromium
├── ungoogled-chromium/   # ungoogled-chromium submodule
├── branding/             # Base browser icons and logos
├── build/                # Build configuration and outputs
│   ├── src/             # Downloaded Chromium source (gitignored)
│   ├── download_cache/  # Download cache (gitignored)
│   ├── args.gn          # macOS build arguments
│   └── flags.macos.gn   # macOS-specific flags
├── script/               # Build scripts
│   ├── build.sh         # Main build script
│   └── sign_and_package_app.sh  # Signing and packaging
├── entitlements/         # macOS app entitlements
└── downloads*.ini        # Resource download configurations
```

## How It Works

### Build Flow

1. **Download Chromium** - The build script downloads Chromium source to `build/src/`
2. **Apply ungoogled-chromium patches** - Privacy patches from ungoogled-chromium
3. **Apply Base patches** - Custom patches from `patches/`
4. **Override files** - Files in `chromium_src/` replace Chromium files during build
5. **Build** - Ninja builds the browser
6. **Package** - Creates signed .dmg with notarization (if configured)

### Adding Custom Features

#### Option 1: File Overrides (chromium_src/)

For substantial changes, place modified files in `chromium_src/` matching Chromium's directory structure:

```bash
# Example: Override the toolbar
mkdir -p chromium_src/chrome/browser/ui/toolbar
cp build/src/chrome/browser/ui/toolbar/toolbar_view.cc chromium_src/chrome/browser/ui/toolbar/
# Edit chromium_src/chrome/browser/ui/toolbar/toolbar_view.cc with your changes
```

#### Option 2: Patches (patches/)

For targeted modifications:

```bash
# Make changes in build/src/
cd build/src
# ... edit files ...

# Create a patch
git diff > ../../patches/my-feature.patch

# Add to patches/series file
echo "my-feature.patch" >> ../../patches/series
```

## Available Commands

| Command | Description |
|---------|-------------|
| `npm run build` | Build for current architecture |
| `npm run build:arm64` | Build for Apple Silicon |
| `npm run build:x86_64` | Build for Intel |
| `npm run build:no-download` | Build without re-downloading source |
| `npm run sign` | Sign and package the app |
| `npm run clean` | Clean build outputs |
| `npm run clean:all` | Remove all build files and cache |

## Configuration

### Build Arguments

Edit `build/args.gn` to customize your build:

```gn
target_cpu = "arm64"  # or "x64" for Intel
is_official_build = true
proprietary_codecs = true
enable_widevine = false  # Disabled for privacy
mac_deployment_target = "11.0"
```

### Signing (Optional)

For notarized builds, set environment variables:

```bash
export MACOS_CERTIFICATE_NAME="Developer ID Application: Your Name (TEAMID)"
export PROD_MACOS_NOTARIZATION_APPLE_ID="your@email.com"
export PROD_MACOS_NOTARIZATION_TEAM_ID="YOURTEAMID"
export PROD_MACOS_NOTARIZATION_PWD="app-specific-password"
```

Or comment out signing code in `script/sign_and_package_app.sh` for ad-hoc signing.

## Development Workflow

### First Build

```bash
# Full build (takes 1-3 hours depending on your Mac)
npm run build
```

### Incremental Changes

```bash
# Make changes to chromium_src/ or patches/
# Then rebuild (much faster)
npm run build:no-download
```

### Testing Changes

```bash
# Run the built browser
open build/src/out/Default/Chromium.app

# Or with custom user data directory
open build/src/out/Default/Chromium.app --args --user-data-dir=/tmp/base-test
```

## Troubleshooting

### Build fails with "greadlink: command not found"

```bash
brew install coreutils
```

### Not enough disk space

Chromium builds require ~60-80GB:
- Source code: ~30GB
- Build outputs: ~20-50GB

### Build fails after download

```bash
npm run clean:all
npm run build
```

### Want to use existing ungoogled-chromium source

If you already have ungoogled-chromium downloaded, you can copy the `build/` directory:

```bash
cp -r /path/to/ungoogled-chromium-macos/build ./
npm run build:no-download
```

## Architecture Comparison

This project combines:

- **ungoogled-chromium** - Privacy patches and Google service removal
- **brave-core architecture** - Modular structure for custom features
- **macOS focus** - Optimized for Apple Silicon and Intel Macs

Similar to how Brave extends Chromium, Base Core extends ungoogled-chromium.

## Branding

Base browser icons and branding assets are in the `branding/` directory. The build process will use these to customize the browser appearance.

## Releases

See [RELEASES.md](RELEASES.md) for release process and version history.

To create a new release:
```bash
# Update VERSION file
echo "0.2.0" > VERSION

# Commit and tag
git add VERSION
git commit -m "Prepare release v0.2.0"
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin main
git push origin v0.2.0
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## Resources

- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium)
- [ungoogled-chromium-macos](https://github.com/ungoogled-software/ungoogled-chromium-macos)
- [Chromium Development](https://www.chromium.org/developers/)
- [brave-core](https://github.com/brave/brave-core)

## License

Mozilla Public License 2.0 (MPL-2.0). See [LICENSE](LICENSE) for details.
