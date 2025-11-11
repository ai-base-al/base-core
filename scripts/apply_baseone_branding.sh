#!/bin/bash
# Apply BaseOne branding to Chromium source
# Company: BaseCode LLC
# Product: BaseOne
# Bundle ID: al.base.one

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="/Volumes/External/BaseChrome/ungoogled-chromium/build/src"

echo "========================================="
echo "Applying BaseOne Branding"
echo "========================================="
echo ""
echo "Company: BaseCode LLC"
echo "Product: BaseOne"
echo "Bundle ID: al.base.one"
echo "Source: $SRC_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Source directory not found: $SRC_DIR"
    exit 1
fi

cd "$SRC_DIR"

# Check if we're in a git repo (chromium source should be)
if [ ! -d ".git" ]; then
    echo "WARNING: Not a git repository. Continuing anyway..."
fi

# Find all .grd and .grdp files in chrome/app
GRD_FILES=$(find chrome/app -name "*.grd" -o -name "*.grdp" 2>/dev/null)

if [ -z "$GRD_FILES" ]; then
    echo "ERROR: No .grd/.grdp files found in chrome/app"
    exit 1
fi

echo "Found resource files to update:"
echo "$GRD_FILES" | head -5
echo "... ($(echo "$GRD_FILES" | wc -l | tr -d ' ') files total)"
echo ""

# Backup files before modification
echo "Creating backups..."
for file in $GRD_FILES; do
    if [ -f "$file" ] && [ ! -f "$file.bak" ]; then
        cp "$file" "$file.bak"
    fi
done

# Apply string replacements
echo "Applying branding replacements..."
echo ""

# Count replacements
TOTAL=0

# Replace "Chromium" with "BaseOne" (case-sensitive, preserves XML)
echo "1. Replacing 'Chromium' → 'BaseOne'..."
for file in $GRD_FILES; do
    if [ -f "$file" ]; then
        COUNT=$(grep -o "Chromium" "$file" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$COUNT" -gt 0 ]; then
            sed -i '' 's/Chromium/BaseOne/g' "$file"
            echo "   $file: $COUNT replacements"
            TOTAL=$((TOTAL + COUNT))
        fi
    fi
done

echo "   Total: $TOTAL replacements"
echo ""

# Update copyright strings
echo "2. Updating copyright strings with BaseCode LLC..."
COUNT=0
for file in $GRD_FILES; do
    if [ -f "$file" ]; then
        # Replace "The Chromium Authors" with "BaseCode LLC. Based on Chromium, Copyright The Chromium Authors"
        if grep -q "The Chromium Authors" "$file" 2>/dev/null; then
            sed -i '' 's/Copyright © [0-9]* The Chromium Authors/Copyright © 2025 BaseCode LLC. Based on Chromium, Copyright The Chromium Authors/g' "$file"
            sed -i '' 's/Copyright [0-9]* The Chromium Authors/Copyright 2025 BaseCode LLC. Based on Chromium, Copyright The Chromium Authors/g' "$file"
            sed -i '' 's/The Chromium Authors/BaseCode LLC/g' "$file"
            COUNT=$((COUNT + 1))
            echo "   $file"
        fi
    fi
done
echo "   Total: $COUNT files updated"
echo ""

# Show summary
echo "========================================="
echo "Branding Applied Successfully"
echo "========================================="
echo ""
echo "Summary:"
echo "- Product name: $TOTAL instances of 'Chromium' → 'BaseOne'"
echo "- Copyright: $COUNT files updated with BaseCode LLC"
echo ""
echo "Files modified:"
git diff --name-only chrome/app/ 2>/dev/null || find chrome/app -name "*.grd" -newer chrome/app/*.grd.bak 2>/dev/null | head -10
echo ""
echo "Next steps:"
echo "1. Review changes: cd $SRC_DIR && git diff chrome/app/"
echo "2. Generate patch: cd $BASE_DIR && ./scripts/generate_branding_patch.sh"
echo "3. Build: cd $BASE_DIR && ./scripts/6_build_incremental.sh"
echo ""
