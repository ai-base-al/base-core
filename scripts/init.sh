#!/bin/bash
# BaseOne - Initial Setup Script
# This script sets up a complete build environment from scratch
# Run this only once or when setting up a new development machine
#
# ============================================================================
# WARNING: THIS SCRIPT SHOULD ONLY BE RUN BY A HUMAN OPERATOR
# ============================================================================
# DO NOT run this script from:
# - LLMs (Large Language Models)
# - AI Agents
# - Automated systems
# - CI/CD pipelines
#
# This script:
# 1. Calls ungoogled-chromium/build.sh which CLONES source code
# 2. Takes 2-4 hours to complete
# 3. Can OVERWRITE existing work if run accidentally
#
# For daily development, use: ./scripts/build_incremental.sh
# ============================================================================

set -e
set -o pipefail  # Make pipeline errors propagate correctly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
UNGOOGLED_DIR="$(dirname "$BASE_CORE_DIR")/ungoogled-chromium-macos"
SRC_DIR="$BASE_CORE_DIR/src"
LOGS_DIR="$BASE_CORE_DIR/logs"
LOG_FILE="$LOGS_DIR/build.log"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

echo "BaseOne - Initial Setup"
echo "Log file: $LOG_FILE"
echo "========================"
echo ""
echo "This will set up a complete build environment"
echo "Expected time: 2-4 hours (includes full Chromium build)"
echo ""
echo "Base Core directory: $BASE_CORE_DIR"
echo "ungoogled-chromium directory: $UNGOOGLED_DIR"
echo "Source directory: $SRC_DIR"
echo ""

# Check if ungoogled-chromium exists, clone if not
if [ ! -d "$UNGOOGLED_DIR" ]; then
  echo "ungoogled-chromium-macos directory not found at $UNGOOGLED_DIR"
  echo "Cloning ungoogled-chromium-macos repository..."
  echo ""

  PARENT_DIR="$(dirname "$BASE_CORE_DIR")"
  cd "$PARENT_DIR"

  if git clone https://github.com/ungoogled-software/ungoogled-chromium-macos.git ungoogled-chromium-macos; then
    echo "Successfully cloned ungoogled-chromium-macos"
    echo ""
  else
    echo "ERROR: Failed to clone ungoogled-chromium-macos"
    echo ""
    echo "Please clone manually:"
    echo "  cd $PARENT_DIR"
    echo "  git clone https://github.com/ungoogled-software/ungoogled-chromium-macos.git ungoogled-chromium-macos"
    echo "  cd ungoogled-chromium-macos"
    echo "  git submodule update --init --recursive"
    echo ""
    echo "Then run this script again."
    exit 1
  fi

  cd "$BASE_CORE_DIR"
fi

# Initialize git submodules if not already done
if [ ! -f "$UNGOOGLED_DIR/ungoogled-chromium/utils/downloads.py" ]; then
  echo "Initializing git submodules..."
  cd "$UNGOOGLED_DIR"
  git submodule update --init --recursive 2>&1 | tee -a "$LOG_FILE"
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to initialize git submodules"
    exit 1
  fi
  echo ""
  echo "=========================================="
  echo "Repository setup complete!"
  echo "=========================================="
  echo ""
  echo "Location: $UNGOOGLED_DIR"
  echo "Submodule: $UNGOOGLED_DIR/ungoogled-chromium"
  echo ""
  echo "Next steps: This script will now automatically:"
  echo ""
  echo "1. Download Chromium source (~10GB)"
  echo "   - Uses: ungoogled-chromium/retrieve_and_unpack_resource.sh"
  echo "   - Downloads source code, dependencies, and build tools"
  echo ""
  echo "2. Build vanilla Chromium (2-4 hours)"
  echo "   - Applies ungoogled-chromium patches"
  echo "   - Builds base browser with: ninja -C out/Default chrome"
  echo ""
  echo "3. Apply BaseOne patches"
  echo "   - Applies custom patches from: patches/"
  echo "   - Runs: ./scripts/patch.sh"
  echo ""
  echo "4. Rebuild with BaseOne branding"
  echo "   - Incremental rebuild with Base branding"
  echo "   - Runs: ./scripts/build.sh"
  echo ""
  echo "Total time: 2-4 hours | Log: logs/build.log"
  echo ""
  cd "$BASE_CORE_DIR"
fi

# ============================================================================
# CHECK PATCHES AND CONFIRM BUILD
# ============================================================================

echo ""
echo "=========================================="
echo "    Patch Status & Build Confirmation"
echo "=========================================="
echo ""

# Check if source directory already exists and has patches applied
PATCHES_APPLIED=false
if [ -d "$SRC_DIR" ]; then
  echo "Source directory exists: $SRC_DIR"
  echo ""

  # Check if BaseOne patches might be applied by looking for marker files or changes
  if [ -f "$SRC_DIR/.baseone_patches_applied" ]; then
    PATCHES_APPLIED=true
    echo "BaseOne patches appear to be ALREADY APPLIED"
    echo ""
  else
    echo "Source directory exists but patches may not be applied"
    echo ""
  fi
fi

# Show which patches will be applied
echo "BaseOne patches to be applied (from patches/series):"
echo ""
if [ -f "$BASE_CORE_DIR/patches/series" ]; then
  # Read and display patches from series file
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    if [ -n "$line" ] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      echo "  - $line"
    fi
  done < "$BASE_CORE_DIR/patches/series"
else
  echo "  (No patches/series file found)"
fi
echo ""

if [ "$PATCHES_APPLIED" = true ]; then
  echo "WARNING: Patches already applied. Re-applying may cause conflicts."
  echo ""
fi

# Check if source directory already exists - do this BEFORE confirmations
# so we don't waste time on confirmations if source exists and user doesn't want to rebuild
if [ -d "$SRC_DIR" ]; then
  echo "Warning: Source directory already exists at $SRC_DIR"
  echo ""
  read -p "Do you want to remove it and start fresh? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing existing source directory..."
    rm -rf "$SRC_DIR"
    echo ""
  else
    echo "Keeping existing source directory"
    echo "If you want to rebuild, use ./scripts/build_incremental.sh instead"
    exit 0
  fi
fi

echo "This script will:"
echo "  1. Download Chromium source (~10GB) if not present"
echo "  2. Apply ungoogled-chromium patches"
echo "  3. Apply BaseOne custom patches (listed above)"
echo "  4. Build full Chromium (2-4 hours)"
echo ""
read -p "Continue with full build? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Build cancelled."
  echo ""
  echo "To build manually:"
  echo "  - Apply patches: ./scripts/patch.sh"
  echo "  - Build incrementally: ./scripts/build.sh"
  exit 0
fi

# ============================================================================
# SAFETY CONFIRMATIONS - PREVENT ACCIDENTAL EXECUTION
# ============================================================================

echo ""
echo "=========================================="
echo "         DANGER - READ CAREFULLY"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Clone Chromium source code (~10GB download)"
echo "  2. Run a FULL build (2-4 hours)"
echo "  3. Call ungoogled-chromium/build.sh (DANGEROUS)"
echo ""
echo "This should ONLY be run:"
echo "  - On first-time setup"
echo "  - By a HUMAN operator"
echo "  - When you understand the consequences"
echo ""
echo "For daily development, use: ./scripts/build_incremental.sh"
echo ""
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled. Good choice."
  exit 0
fi

echo ""
echo "=========================================="
echo "       FINAL CONFIRMATION REQUIRED"
echo "=========================================="
echo ""
echo "You are about to run a DANGEROUS operation that:"
echo "  - Takes 2-4 hours"
echo "  - Cannot be easily stopped"
echo "  - Will overwrite existing builds"
echo ""
echo "Type 'CONFIRM' (all caps) to proceed, or anything else to cancel:"
read -r CONFIRMATION

if [ "$CONFIRMATION" != "CONFIRM" ]; then
  echo ""
  echo "Cancelled. You entered: '$CONFIRMATION'"
  echo "You must type exactly: CONFIRM"
  exit 0
fi

echo ""
echo "Proceeding with full build setup..."
echo ""

echo "Step 1: Checking Chromium source"
if [ -d "$UNGOOGLED_DIR/build/src/.git" ]; then
  echo "Source already exists at $UNGOOGLED_DIR/build/src"

  # Ensure symlink exists
  if [ ! -L "$SRC_DIR" ]; then
    echo "Creating symlink: $SRC_DIR -> $UNGOOGLED_DIR/build/src"
    ln -s "$UNGOOGLED_DIR/build/src" "$SRC_DIR"
  fi
else
  echo "Source not found - will be cloned by retrieve_and_unpack_resource.sh"
fi
echo ""

echo "Step 2: Setting up build environment"
echo ""

cd "$UNGOOGLED_DIR"
export PYTHON=python3.13

_root_dir="$UNGOOGLED_DIR"
_download_cache="$_root_dir/build/download_cache"
_src_dir="$_root_dir/build/src"
_main_repo="$_root_dir/ungoogled-chromium"
_arch="arm64"

# Create necessary directories
mkdir -p "$_download_cache"
mkdir -p "$_src_dir"

# Retrieve and unpack resources (skip clone with -d flag)
echo "Retrieving dependencies..."
"$_root_dir/retrieve_and_unpack_resource.sh" -d -g $_arch 2>&1 | tee -a "$LOG_FILE"

mkdir -p "$_src_dir/out/Default"

# Apply patches and substitutions
echo "Applying ungoogled-chromium patches..."
python3 "$_main_repo/utils/prune_binaries.py" "$_src_dir" "$_main_repo/pruning.list" 2>&1 | tee -a "$LOG_FILE"
python3 "$_main_repo/utils/patches.py" apply "$_src_dir" "$_main_repo/patches" "$_root_dir/patches" 2>&1 | tee -a "$LOG_FILE"

# Apply tarball fix if needed
patch -p1 -d "$_src_dir" < "$_root_dir/patches/ungoogled-chromium/macos/tarball-fix-dawn-commit-hash.patch" 2>&1 | tee -a "$LOG_FILE" || true

echo "Applying domain substitutions..."
python3 "$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/domain_regex.list" -f "$_main_repo/domain_substitution.list" "$_src_dir" 2>&1 | tee -a "$LOG_FILE"

# Set build flags
cat "$_main_repo/flags.gn" "$_root_dir/flags.macos.gn" > "$_src_dir/out/Default/args.gn"
echo 'target_cpu = "arm64"' >> "$_src_dir/out/Default/args.gn"

mkdir -p "$_src_dir/third_party/llvm-build/Release+Asserts"
mkdir -p "$_src_dir/third_party/rust-toolchain/bin"

echo "Unpacking build tools..."
"$_root_dir/retrieve_and_unpack_resource.sh" -p $_arch 2>&1 | tee -a "$LOG_FILE"

cd "$_src_dir"

echo "Bootstrapping GN..."
./tools/gn/bootstrap/bootstrap.py -o out/Default/gn --skip-generate-buildfiles 2>&1 | tee -a "$LOG_FILE"

echo "Building Rust bindgen..."
./tools/rust/build_bindgen.py --skip-test 2>&1 | tee -a "$LOG_FILE"

echo "Generating build files..."
./out/Default/gn gen out/Default --fail-on-unused-args 2>&1 | tee -a "$LOG_FILE"

BUILD_SRC="$UNGOOGLED_DIR/build/src"

# Create symlink if needed
if [ ! -L "$SRC_DIR" ]; then
  echo "Creating symlink: $SRC_DIR -> $BUILD_SRC"
  ln -s "$BUILD_SRC" "$SRC_DIR"
fi

echo ""
echo "=========================================="
echo "Initialization complete!"
echo "=========================================="
echo ""
echo "Source location: $BUILD_SRC"
echo "Symlink: $SRC_DIR -> $BUILD_SRC"
echo ""
echo "Next steps:"
echo ""
echo "1. Run full build (2-4 hours):"
echo "   cd ../ungoogled-chromium && export PYTHON=python3.13 && ./build.sh"
echo ""
echo "2. After build completes, for daily development:"
echo "   ./scripts/build_incremental.sh  # Fast incremental builds (10-30 min)"
echo ""
echo "Note: Source code stays in ungoogled-chromium/build/src permanently"
echo "      This prevents re-cloning on future builds!"
