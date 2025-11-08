# Incremental Build Guide

This guide shows you where all the build artifacts are saved and how to do fast incremental builds when adding features.

## 📂 Build Artifacts Location

### Main Directories

```
ungoogled-chromium/
├── build/
│   ├── src/                          # Full Chromium source (30GB)
│   │   ├── out/Default/              # Compiled binaries and objects
│   │   │   ├── Chromium.app          # Main application
│   │   │   ├── chrome                # Chrome binary
│   │   │   ├── chromedriver          # WebDriver for testing
│   │   │   ├── *.o                   # Object files (reused in incremental)
│   │   │   └── args.gn               # Build configuration
│   │   ├── chrome/                   # Chrome source code
│   │   ├── third_party/              # Dependencies
│   │   └── tools/                    # Build tools
│   ├── download_cache/               # Downloaded dependencies (cached)
│   └── ungoogled-chromium_*.dmg      # Final DMG installer
└── ungoogled-chromium/               # ungoogled patches and config
```

### Key Files to Keep for Incremental Builds

**KEEP THESE** - They enable fast incremental builds:

1. **`build/src/`** - Entire source directory (~30GB)
   - Contains all compiled object files
   - Ninja will only recompile changed files

2. **`build/src/out/Default/`** - Build output (~20GB)
   - Compiled binaries and object files
   - GN build files
   - Build configuration

3. **`build/download_cache/`** - Downloaded resources
   - Prevents re-downloading toolchains
   - Saves bandwidth and time

**CAN DELETE** - To save space:

4. **`build/ungoogled-chromium_*.dmg`** - Final DMG
   - Can be recreated from out/Default/Chromium.app
   - Already copied to binaries/

## 🚀 Incremental Build Workflow

### When Adding Features

```bash
# 1. Make your changes (add patches, modify code, etc.)
# Edit files in:
#   - patches/           (your custom patches)
#   - build/src/chrome/  (direct source edits)

# 2. Run incremental build (FAST - only rebuilds changed files)
./run/5_build_macos.sh -d

# Build time: 10-90 minutes (vs 4-6 hours for full build)
```

### What Gets Reused in Incremental Builds

- ✅ All compiled object files (*.o)
- ✅ Third-party libraries
- ✅ Toolchains and dependencies
- ✅ GN build configuration
- 🔄 Only changed files are recompiled
- 🔄 Only affected targets are re-linked

## 📝 Common Scenarios

### Scenario 1: Branding Only (NO BUILD NEEDED)

For just branding changes (name, bundle ID):

```bash
# 1. Apply branding
./features/branding/apply.sh

# 2. Use existing binary - just rename it!
cd ungoogled-chromium/build/src/out/Default
mv Chromium.app "Base Dev.app"

# 3. Update Info.plist in the app
/usr/libexec/PlistBuddy -c "Set :CFBundleName Base Dev" "Base Dev.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier al.base.BaseDev" "Base Dev.app/Contents/Info.plist"

# Done! Test it:
open "Base Dev.app"
```

**Build time**: 0 seconds! Just rename and update plist.

### Scenario 2: Add a Custom Patch (Requires Build)

```bash
# 1. Create your patch
cat > patches/my-feature.patch << 'EOF'
diff --git a/chrome/browser/ui/views/frame/browser_view.cc
--- a/chrome/browser/ui/views/frame/browser_view.cc
+++ b/chrome/browser/ui/views/frame/browser_view.cc
@@ -100,6 +100,7 @@
   // Your code here
EOF

# 2. Add to patch series
echo "my-feature.patch" >> patches/series

# 3. Incremental build
./run/5_build_macos.sh -d
```

**Build time**: 15-30 minutes (only recompiles affected files)

### Scenario 2: Modify Build Flags

```bash
# 1. Edit flags
vim ungoogled-chromium/flags.macos.gn

# Add/change flags like:
# enable_widevine=true
# is_debug=false

# 2. Incremental build
./run/5_build_macos.sh -d
```

**Build time**: 10-20 minutes (GN regenerates, minimal recompile)

### Scenario 3: Edit Source Directly

```bash
# 1. Edit Chromium source
vim build/src/chrome/browser/ui/browser.cc

# 2. Incremental build
./run/5_build_macos.sh -d
```

**Build time**: 5-15 minutes (only affected files recompile)

### Scenario 4: Full Rebuild (Clean)

```bash
# When you need to start fresh:

# Option 1: Clean build output only (keeps source)
rm -rf ungoogled-chromium/build/src/out
./run/5_build_macos.sh -d

# Option 2: Complete fresh build
./run/5_build_macos.sh

# Build time: 4-6 hours (full rebuild)
```

## 🎯 Preserving Build State

### Disk Space Requirements

- **Full build**: ~60GB
  - Source: ~30GB
  - Build output: ~20GB
  - Downloads cache: ~5GB
  - DMG: ~125MB

- **Minimal for incremental**: ~55GB
  - Keep: source + out + cache
  - Remove: DMG (already in binaries/)

### Backup Build State

```bash
# To preserve your build for later:

# 1. Archive the build directory (optional compression)
tar -czf chromium-build-state.tar.gz ungoogled-chromium/build/

# 2. Restore later
tar -xzf chromium-build-state.tar.gz

# 3. Resume building
./run/5_build_macos.sh -d
```

## ⚡ Speed Comparison

| Build Type | Time | What's Compiled |
|------------|------|-----------------|
| Fresh build | 4-6 hours | Everything (54,696 targets) |
| Incremental (small change) | 5-15 min | Changed files only |
| Incremental (medium change) | 15-30 min | Affected subsystem |
| Incremental (large change) | 30-90 min | Multiple subsystems |
| Clean + incremental | 2-3 hours | Everything, but source cached |

## 🔧 Object Files Location

All compiled object files are in:
```
build/src/out/Default/obj/
├── chrome/              # Chrome object files
├── content/             # Content layer objects
├── ui/                  # UI objects
└── third_party/         # Third-party objects
```

**These are reused** - Ninja only recompiles what changed!

## 📊 Build Output Breakdown

```bash
# Check what's using space:
du -sh build/src/out/Default/* | sort -hr | head -20

# Typical breakdown:
# ~8GB   - Chromium Framework
# ~5GB   - Object files
# ~3GB   - Helper apps
# ~2GB   - Chrome binary
# ~1GB   - Debug symbols
```

## 🎓 Pro Tips

1. **Keep build/src intact** - This is your golden source
   - Never delete unless you want a full rebuild
   - Contains all compiled artifacts

2. **Monitor incremental builds**:
   ```bash
   tail -f logs/build_macos_*.log | grep "Building"
   ```

3. **Check what's being rebuilt**:
   ```bash
   # Ninja shows compilation progress
   # Look for lines like:
   # [1234/54696] CXX obj/chrome/browser/browser.o
   # Low numbers = fast incremental build!
   ```

4. **Test without full rebuild**:
   ```bash
   # Run the app directly from build:
   open build/src/out/Default/Chromium.app
   ```

5. **Save multiple versions**:
   ```bash
   # Copy DMG to binaries with descriptive names:
   cp build/*.dmg binaries/chromium-with-my-feature_$(date +%Y%m%d).dmg
   ```

## 🔄 Updating to Newer Chromium Versions

```bash
# 1. Pull latest ungoogled-chromium
cd ungoogled-chromium
git pull
git submodule update --init --recursive

# 2. Check new version
cat ungoogled-chromium/chromium_version.txt

# 3. Fresh build recommended for version updates
./run/5_build_macos.sh

# Note: Incremental builds across versions may fail
```

## 📦 Binary Locations Summary

| Item | Location | Size | Keep? |
|------|----------|------|-------|
| Source code | `build/src/` | ~30GB | ✅ Yes (for incremental) |
| Build output | `build/src/out/Default/` | ~20GB | ✅ Yes (for incremental) |
| Object files | `build/src/out/Default/obj/` | ~5GB | ✅ Yes (enables fast rebuild) |
| Final app | `build/src/out/Default/Chromium.app` | ~500MB | ✅ Yes (can run directly) |
| DMG installer | `build/ungoogled-chromium_*.dmg` | ~125MB | ⚠️ Optional (copy to binaries/) |
| Download cache | `build/download_cache/` | ~5GB | ✅ Yes (prevents re-download) |
| Saved DMGs | `binaries/` | ~125MB each | ✅ Yes (your releases) |

## 🚀 Quick Reference

```bash
# Fast incremental build
./run/5_build_macos.sh -d

# Test current build
open build/src/out/Default/Chromium.app

# Create DMG from current build
cd ungoogled-chromium
./sign_and_package_app.sh

# Check build status
./run/check_status.sh

# Clean and rebuild
rm -rf build/src/out && ./run/5_build_macos.sh -d
```

---

**Bottom line**: Keep `build/src/` and `build/src/out/Default/` to enable fast incremental builds when adding features!