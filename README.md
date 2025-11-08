# Base Core - Privacy-Focused Browser for macOS

Base Dev is a privacy-focused browser built on ungoogled-chromium for macOS.

## Directory Structure

```
base-core/
├── build/                  # Build output directory (generated)
│   ├── src/               # Chromium source code (cloned during build)
│   ├── download_cache/    # Downloaded build dependencies cache
│   └── ...
├── branding/              # Base browser branding assets (icons, logos)
├── config/                # Build configuration files
│   ├── args.gn           # GN build arguments
│   ├── flags.macos.gn    # macOS-specific build flags
│   ├── downloads*.ini    # Download specifications for toolchains
│   └── .gclient.example  # Example gclient configuration
├── docs/                  # Documentation
│   ├── QUICKSTART.md     # Quick start guide
│   └── CONTRIBUTING.md   # Contribution guidelines
├── entitlements/          # macOS app entitlements
├── logs/                  # Build logs (generated)
├── patches/               # Custom patches applied to Chromium
│   └── series            # Patch application order
├── run/                   # Organized build scripts (start here!)
│   ├── 1_update_chromium.sh      # Update Chromium version
│   ├── 2_build_binaries.sh       # Build Chromium (main script)
│   ├── 3_check_build_status.sh   # Monitor build progress
│   ├── 4_stop_build.sh           # Stop running build
│   ├── 5_clean_build.sh          # Clean build files
│   ├── 6_setup_python.sh         # Setup Python 3.11
│   └── README.md                 # Detailed usage guide
├── tools/                 # Build and development tools
│   └── script/           # Build scripts
│       ├── build.sh                      # Main build script
│       ├── retrieve_and_unpack_resource.sh # Resource management
│       ├── apply_overrides.sh            # Apply custom patches
│       └── sign_and_package_app.sh       # macOS app signing
├── ungoogled-chromium/    # ungoogled-chromium submodule/clone
│   ├── patches/          # ungoogled-chromium patches
│   ├── utils/            # Build utilities
│   └── flags.gn          # Base ungoogled-chromium flags
├── base_src.backup/       # Backup of custom source modifications
├── BUILD.gn               # Root build configuration
├── DEPS                   # Dependency specifications
└── LICENSE                # License information
```

## Quick Start

### Prerequisites

- macOS (Apple Silicon - ARM64)
- Python 3.11+ (not 3.14 - has compatibility issues)
- Xcode Command Line Tools
- GNU coreutils (for greadlink): `brew install coreutils`
- ~40GB free disk space
- 4-8 hours for initial build

### Quick Start with Run Scripts

**Easiest way to build:**

```bash
# 1. First time setup (install Python 3.11)
./run/6_setup_python.sh

# 2. Build Chromium
./run/2_build_binaries.sh

# 3. Check build status
./run/3_check_build_status.sh
```

See [run/README.md](run/README.md) for detailed usage of all scripts.

**Available scripts:**
- `1_update_chromium.sh` - Update Chromium version
- `2_build_binaries.sh` - Build Chromium (main command)
- `3_check_build_status.sh` - Monitor build progress
- `4_stop_build.sh` - Stop running build
- `5_clean_build.sh` - Clean build files
- `6_setup_python.sh` - Setup Python 3.11

### Advanced Build Commands

```bash
# Direct build script access (if needed)
bash tools/script/build.sh      # Full build
bash tools/script/build.sh -d   # Incremental build
```

### Build Process

The build script will:
1. Clone Chromium source code (~10-15 min)
2. Download and setup build toolchains (LLVM, Rust, Node.js)
3. Apply ungoogled-chromium patches
4. Apply custom Base patches
5. Generate build files with GN
6. Compile with Ninja (2-4 hours)
7. Sign and package the app

### Build Output

The final app will be located at:
```
build/src/out/Default/Chromium.app
```

## Configuration

### Build Flags

Edit `config/flags.macos.gn` and `config/args.gn` to customize build options:

- `is_debug`: Debug vs Release build
- `is_official_build`: Optimized official build
- `enable_widevine`: DRM support
- `safe_browsing_mode`: Safe browsing (0=disabled, 1=local, 2=full)

### Custom Patches

Add custom patches to `patches/` directory and list them in `patches/series`.

## Development

### Version Information

- **Chromium Version**: 142.0.7444.59
- **Based on ungoogled-chromium**: Latest (commit 6a7a75d0)

### Updating Chromium Version

```bash
cd ungoogled-chromium
git fetch origin
git log --oneline --grep="Update to Chromium"  # Find desired version
git checkout <commit-hash>
cd ..
rm -rf build/src  # Clean old source
./tools/script/build.sh
```

## Troubleshooting

### Python 3.14 Issues

If you see `AttributeError: module 'ast' has no attribute 'Str'`:
```bash
brew install python@3.11
mkdir -p ~/bin
ln -sf /opt/homebrew/bin/python3.11 ~/bin/python3
export PATH="$HOME/bin:/opt/homebrew/bin:$PATH"
```

### Build Failures

Check logs in `logs/` directory:
- `build_142.log` - Main build log
- `logs/ninja_build.log` - Compilation log

### Clean Build

To start completely fresh:
```bash
rm -rf build/src
./tools/script/build.sh
```

## Links

- [Chromium Project](https://www.chromium.org/)
- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium)

## License

See LICENSE file for details.
