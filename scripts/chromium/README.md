# Chromium Build References

This directory contains reference copies of chromium build scripts that have been REMOVED from the main ungoogled-chromium directory for safety.

## Contents

### `build.sh.reference`
**Status**: REMOVED from ungoogled-chromium/ for safety

**Why removed**:
- Clones entire Chromium source code (dangerous - can lose your work)
- Takes 2-4 hours to complete
- Deletes `out/` directory without confirmation
- Too easy to run accidentally

**Safe alternative**:
The `scripts/init.sh` script now implements these build steps directly with:
- 2-step human confirmation (y/N + typing "CONFIRM")
- Clear warnings about dangers
- Explicit logging of all steps
- One script, one job principle

**Reference purpose**:
- Understanding the original ungoogled-chromium build workflow
- Reference when updating our init.sh implementation
- Historical documentation

## Safety Rules

1. **NEVER** put `build.sh` back in `ungoogled-chromium/`
2. **NEVER** run the reference script directly
3. **ALWAYS** use `scripts/init.sh` for first-time setup (requires confirmations)
4. **ALWAYS** use `scripts/build_incremental.sh` for daily development

## Directory Structure

```
base-core/
├── scripts/
│   ├── init.sh                      # Safe first-time setup (HUMAN ONLY)
│   ├── build_incremental.sh         # Daily incremental builds
│   └── chromium/
│       ├── README.md               # This file
│       └── build.sh.reference      # Original ungoogled-chromium build.sh
│
ungoogled-chromium/
├── retrieve_and_unpack_resource.sh  # OK - single purpose utility
├── sign_and_package_app.sh          # OK - single purpose utility
└── build.sh                         # REMOVED - too dangerous
```

## ungoogled-chromium Directory Policy

The `ungoogled-chromium/` directory must remain PRISTINE:
- Contains only original ungoogled-chromium-macos repository files
- NO custom scripts
- NO modifications
- All Base customization in `base-core/` only

This ensures:
- Clear separation between upstream and custom code
- Easy updates from ungoogled-chromium upstream
- No accidental execution of dangerous scripts
- Maintainable codebase

## Implementation Details

Our `scripts/init.sh` implements the chromium build workflow as:

1. **Safety confirmations** (2-step)
2. **Retrieve dependencies** (retrieve_and_unpack_resource.sh -d -g arm64)
3. **Apply patches** (prune_binaries.py, patches.py, domain_substitution.py)
4. **Set build flags** (flags.gn + flags.macos.gn → args.gn)
5. **Unpack tools** (retrieve_and_unpack_resource.sh -p arm64)
6. **Bootstrap GN** (tools/gn/bootstrap/bootstrap.py)
7. **Build Rust bindgen** (tools/rust/build_bindgen.py)
8. **Generate build** (gn gen out/Default)
9. **Build Chrome** (ninja -C out/Default chrome chromedriver)
10. **Sign and package** (sign_and_package_app.sh)

Each step:
- Logs to `logs/build.log`
- Checks for errors
- Exits on failure
- Reports progress clearly

## See Also

- `scripts/README.md` - Complete script reference
- `scripts/init.sh` - Safe first-time setup implementation
- `scripts/build_incremental.sh` - Daily development builds
