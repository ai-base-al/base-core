# Base Core Components

This directory contains reusable components that can be shared across different parts of the browser.

## Overview

Components are self-contained modules that provide specific functionality. They can be used in the browser process, renderer process, or both.

## Directory Structure

```
components/
├── component_name/
│   ├── BUILD.gn           # Build configuration
│   ├── README.md          # Component documentation
│   ├── component_name.h   # Header files
│   ├── component_name.cc  # Implementation files
│   └── test/              # Unit tests
│       └── component_name_unittest.cc
```

## Creating a New Component

1. Create a directory with your component name
2. Add a BUILD.gn file defining the component target
3. Implement your component's functionality
4. Add unit tests
5. Document the component in a README.md

### Example BUILD.gn

```gn
# Copyright (c) 2025 Base Core. All rights reserved.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at https://mozilla.org/MPL/2.0/.

component("my_component") {
  sources = [
    "my_component.cc",
    "my_component.h",
  ]

  deps = [
    "//base",
    "//components/prefs",
  ]
}

source_set("unit_tests") {
  testonly = true
  sources = [
    "test/my_component_unittest.cc",
  ]
  deps = [
    ":my_component",
    "//testing/gtest",
  ]
}
```

## Component Guidelines

1. **Single Responsibility** - Each component should have a clear, focused purpose
2. **Minimal Dependencies** - Avoid unnecessary dependencies on other components
3. **Well-Tested** - Include comprehensive unit tests
4. **Documented** - Provide clear documentation of the component's purpose and API
5. **Reusable** - Design components to be used in multiple contexts

## Common Component Types

- **UI Components** - Reusable UI elements (buttons, menus, dialogs)
- **Service Components** - Background services (sync, storage, networking)
- **Utility Components** - Helper functions and utilities
- **Feature Components** - Complete features that can be enabled/disabled

## Integration

Components can be used by adding them as dependencies in BUILD.gn:

```gn
deps = [
  "//base/components/my_component",
]
```

## Testing

Run component tests:
```bash
ninja -C out/Release base_components_unittests
out/Release/base_components_unittests
```

## Examples

Look at Chromium's existing components for inspiration:
- `//components/prefs` - Preferences system
- `//components/download` - Download management
- `//components/search_engines` - Search engine templates
