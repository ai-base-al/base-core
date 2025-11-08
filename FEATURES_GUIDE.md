# Base Browser Features Guide

Complete guide to adding custom features to your Chromium build.

## 🎯 Feature System Overview

```
features/
├── README.md              # Feature system docs
├── branding/              # Base Dev branding
│   ├── apply.sh          # Apply branding
│   ├── rollback.sh       # Revert to Chromium
│   ├── config.sh         # Configuration
│   ├── icons/            # Custom icons
│   ├── patches/          # Generated patches
│   └── scripts/          # Helper scripts
└── [future-features]/    # More features...
```

## 🚀 Quick Start

### Apply Base Dev Branding

```bash
# 1. Apply the branding
./features/branding/apply.sh

# 2. Build (incremental - fast!)
./run/5_build_macos.sh -d

# 3. Result
# Base Dev.app in build/src/out/Default/
```

**Build time**: 15-30 minutes (vs 4-6 hours fresh build!)

## 📋 Current Features

### 1. Branding - "Base Dev"

**What it does:**
- Changes product name from "Chromium" to "Base Dev"
- Updates bundle ID to `com.base.dev`
- Modifies app name in all UI strings
- Prepares for custom icons

**Files modified:**
- `chrome/app/theme/chromium/BRANDING`
- `chrome/BUILD.gn`
- `chrome/app/framework/Info.plist`
- `chrome/app/app-Info.plist`
- `chrome/app/chromium_strings.grd`

**How to use:**
```bash
# Apply
./features/branding/apply.sh

# Build
./run/5_build_macos.sh -d

# Rollback
./features/branding/rollback.sh
```

**Customization:**
Edit `features/branding/config.sh`:
```bash
export PRODUCT_NAME="Your Name"
export PRODUCT_SHORT_NAME="Short"
export BUNDLE_ID="com.your.app"
```

## 🎨 Adding Custom Icons

### Method 1: Replace Chromium Icons

```bash
# 1. Create your icon files
# See features/branding/icons/README.md

# 2. Create .icns file
iconutil -c icns icons.iconset -o app.icns

# 3. Copy to Chromium source
cp app.icns ungoogled-chromium/build/src/chrome/app/theme/chromium/mac/

# 4. Rebuild
./run/5_build_macos.sh -d
```

### Method 2: Use Icon Generator Script

```bash
# Run icon helper
./features/branding/scripts/generate_icon.sh

# Follow instructions to create custom icons
```

**Icon Requirements:**
- Sizes: 16x16, 32x32, 128x128, 256x256, 512x512, 1024x1024
- Format: PNG → .icns
- Style: Modern, minimal, distinct from Chrome

**Suggested colors:**
- Primary: `#4A90E2` (Blue)
- Accent: `#7B68EE` (Purple)

## 🔧 Creating New Features

### Feature Template

1. **Create directory structure:**
```bash
mkdir -p features/my-feature/{patches,scripts,assets}
```

2. **Create apply.sh:**
```bash
cat > features/my-feature/apply.sh << 'EOF'
#!/bin/bash
# Apply my feature

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../../ungoogled-chromium/build/src"

# Make your changes here
# Backup originals: cp file.txt file.txt.orig
# Modify files
# Create patches if needed

echo "Feature applied! Run ./run/5_build_macos.sh -d to build"
EOF

chmod +x features/my-feature/apply.sh
```

3. **Create README.md:**
```markdown
# My Feature

Description of what this does.

## Usage
./features/my-feature/apply.sh
./run/5_build_macos.sh -d
```

4. **Test:**
```bash
./features/my-feature/apply.sh
./run/5_build_macos.sh -d
```

## 📦 Feature Ideas

### Planned Features

- **Custom New Tab Page** - Replace blank page
- **Built-in Extensions** - Pre-bundle extensions
- **Privacy Hardening** - Additional privacy patches
- **Performance Tweaks** - Optimize for speed
- **Developer Tools** - Enhanced DevTools
- **UI Customization** - Custom themes/colors

### Creating These Features

Each feature follows the same pattern:
1. Identify files to modify
2. Create backup strategy
3. Write apply script
4. Test incremental build
5. Document in README

## ⚡ Incremental Build Tips

**Why incremental builds are fast:**
- Only changed files recompile
- Existing object files (*.o) are reused
- Ninja tracks dependencies automatically

**What triggers recompilation:**
- Modified source files
- Changed headers (and dependencies)
- Build config changes (args.gn)
- New/modified patches

**Build time estimates:**
- String changes: 5-10 minutes
- UI changes: 10-20 minutes
- Core changes: 20-60 minutes
- Major refactor: 1-2 hours

## 🔄 Feature Workflow

### Standard Workflow

```bash
# 1. Apply feature
./features/branding/apply.sh

# 2. Optional: Apply more features
./features/another-feature/apply.sh

# 3. Build (incremental)
./run/5_build_macos.sh -d

# 4. Test
open ungoogled-chromium/build/src/out/Default/Base\ Dev.app

# 5. If issues, rollback and retry
./features/branding/rollback.sh
```

### Multiple Features

```bash
# Apply all features at once (future script)
./run/apply_all_features.sh

# Or manually
./features/branding/apply.sh
./features/custom-ntp/apply.sh
./features/privacy-hardening/apply.sh

# Build once
./run/5_build_macos.sh -d
```

## 🛠️ Advanced: Direct Source Editing

For quick tests without formal features:

```bash
# 1. Edit source directly
vim ungoogled-chromium/build/src/chrome/browser/ui/browser.cc

# 2. Build
./run/5_build_macos.sh -d

# 3. Test
# 4. If good, create proper feature/patch
```

**Note:** Direct edits are lost on clean builds. Create features for permanent changes.

## 📊 Feature Impact on Build Time

| Change Type | Files Affected | Build Time |
|-------------|---------------|------------|
| Branding strings | ~10 files | 10-15 min |
| UI resources | ~50 files | 15-30 min |
| Core browser code | ~100 files | 30-60 min |
| Multiple features | Varies | 20-90 min |

**Tip:** Apply all features before building to minimize total build time.

## 🔍 Debugging Features

### Check what changed:

```bash
# See modified files
cd ungoogled-chromium/build/src
git status

# See specific changes
git diff chrome/app/theme/chromium/BRANDING

# Restore single file
git checkout chrome/app/theme/chromium/BRANDING
```

### Build logs:

```bash
# Watch build
tail -f logs/build_macos_*.log

# Check errors
grep -i error logs/build_macos_*.log
```

## 📚 Resources

- **Feature System**: `features/README.md`
- **Branding**: `features/branding/README.md`
- **Incremental Builds**: `INCREMENTAL_BUILD_GUIDE.md`
- **Build Success**: `BUILD_SUCCESS.md`

## 🎯 Next Steps

1. **Customize branding** - Edit config.sh, add icons
2. **Create custom features** - Use template above
3. **Share features** - Document in features/
4. **Build and test** - Fast incremental builds

---

**Remember:** All features use incremental builds - changes take minutes, not hours!