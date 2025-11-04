# Chromium Source Overrides

This directory contains Base Core's overrides for Chromium source files.

## How It Works

Files placed in this directory will take precedence over the corresponding files in the Chromium source tree during compilation. The directory structure should mirror Chromium's structure.

## Example Structure

```
chromium_src/
├── chrome/
│   └── browser/
│       └── ui/
│           └── toolbar/
│               └── toolbar_button.cc
└── components/
    └── search_engines/
        └── template_url_service.cc
```

## When to Use Overrides

Use `chromium_src/` overrides when:
- Replacing an entire file
- Making substantial changes to a file
- Adding new files to existing directories
- The changes are self-contained

## When to Use Patches Instead

Use patches (in `../patches/`) when:
- Making small, targeted changes
- Modifying code that frequently changes upstream
- The change touches multiple files
- You need fine-grained control over what's modified

## Creating an Override

1. Locate the file you want to override in Chromium source
2. Create the same directory structure under `chromium_src/`
3. Copy or create your modified version
4. Include the license header

Example:
```cpp
// Copyright (c) 2025 Base Core. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Original file: chrome/browser/ui/toolbar/toolbar_button.cc
// Modifications: Added custom branding and styling

#include "chrome/browser/ui/toolbar/toolbar_button.h"
// ... rest of implementation
```

## Guidelines

1. **Document changes** - Add comments explaining what was modified and why
2. **Maintain compatibility** - Try to keep the same API surface as the original
3. **Update regularly** - When Chromium updates, check if overrides need updating
4. **Test thoroughly** - Overrides can break if Chromium's internals change
5. **Minimize overrides** - Only override what's necessary

## Build Integration

The Chromium build system (GN) is configured to prioritize files from `chromium_src/` over the original Chromium files. This is set up in our `BUILD.gn` configuration.

## Updating for New Chromium Versions

When updating to a new Chromium version:
1. Check each override file for compatibility
2. Review Chromium's changelog for changes to overridden files
3. Update overrides as needed
4. Test that the build succeeds and functionality works
