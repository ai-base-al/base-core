# Base Browser Features

This directory contains modular features that can be applied to the base Chromium build.

## Feature Structure

Each feature has its own directory with:

```
features/
├── feature-name/
│   ├── README.md           # Feature description
│   ├── patches/            # Code patches
│   ├── scripts/            # Build scripts
│   ├── assets/             # Icons, resources, etc.
│   └── apply.sh            # Script to apply this feature
└── README.md              # This file
```

## Available Features

### 1. Branding - "Base Dev"
- Custom name: "Base Dev"
- Custom icons and branding
- Product name changes
- Location: `features/branding/`

## Applying Features

```bash
# Apply individual feature
./features/branding/apply.sh

# Apply all features (future)
./run/apply_all_features.sh

# Build with features
./run/5_build_macos.sh -d
```

## Creating New Features

1. Create feature directory: `features/my-feature/`
2. Add patches, scripts, assets
3. Create `apply.sh` script
4. Document in feature's README.md
5. Test with incremental build

## Feature Guidelines

- Keep features modular and independent
- Each feature should be toggleable
- Document all changes
- Test incremental builds
- Provide rollback instructions