#!/usr/bin/env bash
# Base Dev - Continue Build Script
# Use this when source is already set up but build needs to continue

set -eux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium"
SRC_DIR="$UNGOOGLED_DIR/build/src"
MAIN_REPO="$UNGOOGLED_DIR/ungoogled-chromium"
LOG_FILE="$BASE_CORE_DIR/logs/build.log"

mkdir -p "$BASE_CORE_DIR/logs"

echo "Base Dev - Continue Build" | tee -a "$LOG_FILE"
echo "========================" | tee -a "$LOG_FILE"
echo ""
echo "Source directory: $SRC_DIR"
echo "Log file: $LOG_FILE"
echo ""

# Create out/Default directory
echo "Step 1: Creating out/Default directory..." | tee -a "$LOG_FILE"
mkdir -p "$SRC_DIR/out/Default"

# Set build flags
echo "Step 2: Setting build flags..." | tee -a "$LOG_FILE"
cat "$MAIN_REPO/flags.gn" "$UNGOOGLED_DIR/flags.macos.gn" > "$SRC_DIR/out/Default/args.gn"
echo 'target_cpu = "arm64"' >> "$SRC_DIR/out/Default/args.gn"

# Retrieve arch-specific resources (rust, clang, node - already done but ensure dirs exist)
echo "Step 3: Ensuring toolchain directories exist..." | tee -a "$LOG_FILE"
mkdir -p "$SRC_DIR/third_party/llvm-build/Release+Asserts"
mkdir -p "$SRC_DIR/third_party/rust-toolchain/bin"

# Check if bindgen exists
if [ ! -f "$SRC_DIR/third_party/rust-toolchain/bin/bindgen" ]; then
    echo "ERROR: bindgen not found. Please run build_bindgen.py first" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Bindgen found: $(ls -lh $SRC_DIR/third_party/rust-toolchain/bin/bindgen)" | tee -a "$LOG_FILE"

cd "$SRC_DIR"

# Bootstrap GN
echo "Step 4: Bootstrapping GN..." | tee -a "$LOG_FILE"
./tools/gn/bootstrap/bootstrap.py -o out/Default/gn --skip-generate-buildfiles 2>&1 | tee -a "$LOG_FILE"

# Generate build files with GN
echo "Step 5: Generating build files with GN..." | tee -a "$LOG_FILE"
./out/Default/gn gen out/Default --fail-on-unused-args 2>&1 | tee -a "$LOG_FILE"

# Build with ninja
echo "Step 6: Building with ninja (this will take 2-4 hours)..." | tee -a "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
ninja -C out/Default chrome chromedriver 2>&1 | tee -a "$LOG_FILE"

BUILD_EXIT=$?

echo "Build finished at: $(date)" | tee -a "$LOG_FILE"

if [ $BUILD_EXIT -eq 0 ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "==========================================" | tee -a "$LOG_FILE"
    echo "Build completed successfully!" | tee -a "$LOG_FILE"
    echo "==========================================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "Browser location: $SRC_DIR/out/Default/Chromium.app" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "To sign and package:" | tee -a "$LOG_FILE"
    echo "  cd $UNGOOGLED_DIR && ./sign_and_package_app.sh" | tee -a "$LOG_FILE"
else
    echo "" | tee -a "$LOG_FILE"
    echo "ERROR: Build failed with exit code $BUILD_EXIT" | tee -a "$LOG_FILE"
    echo "Check logs/build.log for details" | tee -a "$LOG_FILE"
    exit 1
fi
