#!/bin/bash
# Base Dev - Apply Patches Script
# This script applies Base Dev custom patches to the source tree

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"
PATCHES_DIR="$BASE_CORE_DIR/patches"
SRC_DIR="$BASE_CORE_DIR/src"

echo "Base Dev - Apply Patches"
echo "========================"
echo ""
echo "Patches directory: $PATCHES_DIR"
echo "Source directory: $SRC_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory not found at $SRC_DIR"
  echo "Run ./scripts/init.sh first to set up the build environment"
  exit 1
fi

# Check if patches directory exists
if [ ! -d "$PATCHES_DIR" ]; then
  echo "Error: Patches directory not found at $PATCHES_DIR"
  exit 1
fi

# Check if series file exists
if [ ! -f "$PATCHES_DIR/series" ]; then
  echo "Warning: No patches/series file found"
  echo "No patches to apply"
  exit 0
fi

# Navigate to source directory
cd "$SRC_DIR"

# Apply patches from series file
echo "Applying patches from series file..."
while IFS= read -r patch_name; do
  # Skip empty lines and comments
  [[ -z "$patch_name" || "$patch_name" =~ ^[[:space:]]*# ]] && continue

  patch_file="$PATCHES_DIR/$patch_name"

  if [ ! -f "$patch_file" ]; then
    echo "Warning: Patch file not found: $patch_file"
    continue
  fi

  echo "  Applying: $patch_name"

  # Check if patch has already been applied
  if git apply --check "$patch_file" 2>/dev/null; then
    git apply "$patch_file"
    echo "    ✓ Applied successfully"
  else
    # Check if already applied
    if git apply --reverse --check "$patch_file" 2>/dev/null; then
      echo "    ⊙ Already applied, skipping"
    else
      echo "    ✗ Failed to apply"
      echo ""
      echo "Error: Patch $patch_name failed to apply"
      echo "This might indicate conflicts with the current source tree"
      exit 1
    fi
  fi
done < "$PATCHES_DIR/series"

echo ""
echo "All patches applied successfully!"
