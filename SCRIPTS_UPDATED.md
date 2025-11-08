# Scripts Updated for Python 3.13 and depot_tools Patching

## Changes Made (Nov 8, 2025)

All build scripts have been updated to:
1. Use Python 3.13 explicitly (NOT 3.14 which has ast.Str compatibility issues)
2. Automatically patch depot_tools after cloning to fix Python 3.14 AST module changes
3. Add comments explaining the Python version requirement

## Updated Scripts

### scripts/5_configure_build.sh
- Added Python 3.13 requirement comment
- Added automatic depot_tools patching after source cloning
- Patches are applied before build configuration

### scripts/5_build_full.sh
- Added Python 3.13 requirement comment
- Added automatic depot_tools patching
- Ensures compatibility before full 2-4 hour build

### scripts/6_build_incremental.sh
- Added Python 3.13 requirement comment
- Added automatic depot_tools patching
- Ensures compatibility for 10-30 minute incremental builds

## Python Version Notes

**Use Python 3.13:**
```bash
export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:$PATH"
```

**Why NOT Python 3.14:**
- Python 3.14 removed `ast.Str`, `ast.Num`, and `ast.NameConstant`
- These were replaced with `ast.Constant`
- depot_tools gclient_eval.py uses the old AST attributes
- Results in: `AttributeError: module 'ast' has no attribute 'Str'`

**Fix Applied:**
The tools/patch_depot_tools.py script fixes this by:
1. Replacing `isinstance(node, ast.Str)` with `isinstance(node, ast.Constant) and isinstance(node.value, str)`
2. Updating Python shebangs to use python3.11 (compatible version)
3. Patching gclient_eval.py to work with Python 3.14+

## Automatic Patching

All build scripts now include this check:
```bash
# Patch depot_tools for Python 3.14 compatibility if needed
if [ -d "uc_staging/depot_tools" ] && [ ! -f "uc_staging/depot_tools/.patched" ]; then
    echo -e "${GREEN}✓${NC} Patching depot_tools for Python compatibility..."
    python3 "$ROOT_DIR/tools/patch_depot_tools.py" "$SRC_DIR/uc_staging/depot_tools"
    touch "$SRC_DIR/uc_staging/depot_tools/.patched"
    echo ""
fi
```

This ensures depot_tools is patched exactly once, automatically, before any build operation.

## Next Steps

1. All background builds have been stopped
2. Scripts are now ready with Python 3.13 compatibility
3. depot_tools will be automatically patched on next build
4. Run any of these scripts to start a build:
   - `./scripts/5_configure_build.sh` - Configure only
   - `./scripts/5_build_full.sh` - Full 2-4 hour build
   - `./scripts/6_build_incremental.sh` - Fast 10-30 min incremental build
   - `./scripts/7_apply_strings_and_build.sh` - Apply string changes + incremental build
