# Base Core

Base Core is a set of changes, APIs, and scripts used for customizing ungoogled-chromium to create the Base browser.

## Overview

This repository is modeled after brave-core and provides:
- Custom browser features and UI modifications
- Privacy-focused enhancements built on ungoogled-chromium
- Patch management system for Chromium modifications
- Build orchestration and tooling

## Architecture

Base Core follows a modular architecture similar to Brave:

```
base-core/
├── browser/         # Browser process code
├── chromium_src/    # Chromium source overrides
├── components/      # Reusable components
├── patches/         # Patches applied to Chromium
├── renderer/        # Renderer process code
├── ui/              # User interface components
├── build/           # Build configuration
├── script/          # Build and sync scripts
└── resources/       # Assets and localization
```

## Getting Started

### Prerequisites

- Python 3.8+
- Node.js 18+
- depot_tools (for Chromium development)
- Ninja build system
- GN build tool

### Installation

1. **Install depot_tools:**
```bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=/path/to/depot_tools:$PATH
```

2. **Clone this repository into a Chromium source structure:**
```bash
mkdir chromium
cd chromium
# This will be the 'src' directory
git clone https://github.com/ai-base-al/base-core.git base
cd base
```

3. **Initialize and download Chromium/ungoogled-chromium:**
```bash
npm install
npm run init
```

This will download several GB of Chromium source code.

4. **Sync dependencies and apply patches:**
```bash
npm run sync
```

## Building

### Build Modes

```bash
# Release build (optimized)
npm run build:Release

# Debug build (with symbols)
npm run build:Debug

# Component build (faster incremental builds)
npm run build:Component

# Static build
npm run build:Static
```

### Custom GN Configuration

```bash
# Generate build files with custom args
npm run gn

# Or manually with GN:
gn gen out/Release --args="import(\"//base/build/args.gn\")"
```

### Build Arguments

Edit `build/args.gn` to customize your build. Key options:
- `is_official_build`: Enable optimizations
- `proprietary_codecs`: Enable media codec support
- `enable_widevine`: Enable DRM (disabled by default)

## Development Workflow

### Making Changes

1. **Chromium Source Overrides:**
   - Place override files in `chromium_src/` matching the Chromium directory structure
   - These files take precedence during compilation

2. **Patches:**
   - Add `.patch` files to `patches/`
   - Run `npm run apply_patches` to apply them

3. **Custom Components:**
   - Add new features in `components/`, `browser/`, `ui/`, or `renderer/`

### Testing

```bash
# Run unit tests
npm run test:unit

# Run browser tests
npm run test:browser

# Run all tests
npm test
```

## Directory Structure

### Core Directories

- **`browser/`** - Browser process implementations (UI, services, APIs)
- **`chromium_src/`** - File overrides for Chromium source (take precedence during build)
- **`components/`** - Reusable components shared across processes
- **`patches/`** - Patch files applied to modify Chromium code
- **`renderer/`** - Renderer process customizations
- **`ui/`** - User interface code and resources
- **`net/`** - Network layer modifications
- **`services/`** - Backend service implementations

### Build & Config

- **`build/`** - Build system files and GN configurations
- **`script/`** - Build scripts, sync utilities, and patch management
- **`BUILD.gn`** - Main GN build file
- **`DEPS`** - Dependency declarations
- **`package.json`** - npm scripts and project metadata

### Platform-Specific

- **`android/`** - Android platform code
- **`ios/`** - iOS platform code

## Patching System

Base Core uses two methods to modify Chromium:

1. **chromium_src overrides:** Direct file replacements that take precedence
2. **patches/:** Git patch files applied during sync

### Creating a Patch

```bash
# Make changes in the Chromium source tree
cd ../chromium

# Create a patch
git diff > ../base/patches/my-feature.patch
```

### Applying Patches

```bash
npm run apply_patches
```

## ungoogled-chromium Integration

Base Core is built on top of ungoogled-chromium, which:
- Removes Google service dependencies
- Implements domain substitution for privacy
- Prunes pre-built binaries
- Provides a cleaner base for customization

Version tracking follows ungoogled-chromium's tag format: `{chromium_version}-{revision}`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

This project is licensed under the Mozilla Public License 2.0 (MPL-2.0). See [LICENSE](LICENSE) for details.

## Resources

- [Chromium Development](https://www.chromium.org/developers/)
- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium)
- [GN Build Configuration](https://gn.googlesource.com/gn/)
- [Ninja Build System](https://ninja-build.org/)

## Support

For issues and feature requests, please use the GitHub issue tracker.
