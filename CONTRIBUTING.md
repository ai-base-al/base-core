# Contributing to Base Core

Thank you for your interest in contributing to Base Core! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Making Changes](#making-changes)
- [Submitting Changes](#submitting-changes)
- [Testing](#testing)
- [Patch Management](#patch-management)

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Follow the setup instructions in [README.md](README.md)
4. Create a feature branch for your changes

## Development Setup

### Prerequisites

Ensure you have the required tools installed:
- Python 3.8 or higher
- Node.js 18+ and npm 9+
- depot_tools from Chromium project
- Ninja build system
- GN build configuration tool

### Initial Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/base-core.git
cd base-core

# Add upstream remote
git remote add upstream https://github.com/ai-base-al/base-core.git

# Install dependencies
npm install

# Initialize Chromium source
npm run init

# Sync and apply patches
npm run sync
```

## Code Style

### C++ Code
- Follow [Chromium C++ Style Guide](https://chromium.googlesource.com/chromium/src/+/main/styleguide/c++/c++.md)
- Use 2 spaces for indentation
- Keep lines under 80 characters when possible

### JavaScript/TypeScript
- Use ESLint configuration provided in `.eslintrc.js`
- Run `npm run lint` before committing
- Format code with Prettier: `npm run format`

### Python
- Follow PEP 8 style guide
- Use 4 spaces for indentation
- Use type hints where applicable

### File Headers

Include license headers in new files:

```cpp
// Copyright (c) 2025 Base Core. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.
```

## Making Changes

### Branch Naming

Use descriptive branch names:
- `feature/add-dark-mode`
- `fix/memory-leak-issue`
- `refactor/cleanup-network-code`
- `docs/update-build-instructions`

### Commit Messages

Write clear, descriptive commit messages:

```
Short summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Include motivation for the change and contrast with previous behavior.

- Bullet points are okay
- Use imperative mood ("Add feature" not "Added feature")

Fixes #123
```

### Types of Changes

#### 1. Chromium Source Overrides

Place override files in `chromium_src/` matching Chromium's directory structure:

```
chromium_src/
└── chrome/
    └── browser/
        └── ui/
            └── toolbar/
                └── toolbar_button.cc
```

These files take precedence over Chromium source during compilation.

#### 2. Patches

For modifications to existing Chromium files:

1. Make changes in the Chromium source tree (outside base-core)
2. Generate a patch:
   ```bash
   git diff > patches/descriptive-name.patch
   ```
3. Document the patch purpose in `patches/README.md`

#### 3. New Components

Add new features in appropriate directories:
- `browser/` - Browser process code
- `components/` - Reusable components
- `renderer/` - Renderer process code
- `ui/` - UI components

Each component should have:
- `BUILD.gn` - Build configuration
- `README.md` - Documentation
- Unit tests

## Submitting Changes

### Before Submitting

1. **Build successfully:**
   ```bash
   npm run build:Release
   ```

2. **Run tests:**
   ```bash
   npm test
   ```

3. **Check code style:**
   ```bash
   npm run lint
   npm run format
   ```

4. **Update documentation:**
   - Update README.md if adding features
   - Add comments to complex code
   - Update CHANGELOG.md (if present)

### Pull Request Process

1. **Update your branch:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Push to your fork:**
   ```bash
   git push origin feature/your-feature
   ```

3. **Create a Pull Request:**
   - Use a clear, descriptive title
   - Reference related issues
   - Describe what changed and why
   - Include screenshots for UI changes
   - List testing performed

4. **PR Template:**
   ```markdown
   ## Description
   Brief description of changes

   ## Motivation
   Why is this change needed?

   ## Changes Made
   - Change 1
   - Change 2

   ## Testing
   - [ ] Unit tests pass
   - [ ] Manual testing completed
   - [ ] No regressions found

   ## Screenshots (if applicable)

   ## Related Issues
   Fixes #123
   ```

### Code Review

- Address all review comments
- Push additional commits to the same branch
- Request re-review when ready
- Be respectful and constructive

## Testing

### Unit Tests

```bash
# Run all unit tests
npm run test:unit

# Run specific test suite
ninja -C out/Release base_unittests
out/Release/base_unittests --gtest_filter="MyTest.*"
```

### Browser Tests

```bash
# Run browser tests
npm run test:browser

# Run specific browser test
ninja -C out/Release browser_tests
out/Release/browser_tests --gtest_filter="MyBrowserTest.*"
```

### Manual Testing

1. Build the browser
2. Test affected functionality
3. Check for regressions
4. Test on different platforms (if possible)

## Patch Management

### Understanding Patches

Patches modify Chromium source code without maintaining a full fork. Benefits:
- Easier to update to new Chromium versions
- Clear separation of custom code
- Smaller repository size

### Creating Patches

```bash
# Work in Chromium source tree
cd ../chromium/src

# Make your changes
# ... edit files ...

# Create patch
git add -A
git diff --staged > ../../base/patches/my-feature.patch

# Or for specific files
git diff HEAD path/to/file.cc > ../../base/patches/specific-fix.patch
```

### Patch Guidelines

- Keep patches focused and atomic
- Document patch purpose and reasoning
- Update patches when rebasing to new Chromium versions
- Test that patches apply cleanly

### Updating Patches for New Chromium Versions

```bash
# Sync to new Chromium version
npm run sync

# If patches fail to apply:
# 1. Note which patches failed
# 2. Manually apply changes to new code
# 3. Regenerate patches
# 4. Test thoroughly
```

## Build Configuration

### GN Args

Customize builds by editing `build/args.gn` or passing args:

```bash
gn gen out/Custom --args='
  is_debug=false
  is_component_build=false
  proprietary_codecs=true
  enable_widevine=false
'
```

### Common Build Issues

**Issue: Missing depot_tools**
```bash
export PATH=/path/to/depot_tools:$PATH
```

**Issue: Patches fail to apply**
```bash
npm run sync -- --force
# Then manually resolve conflicts
```

**Issue: Build failures**
```bash
# Clean build
rm -rf out/
npm run gn
npm run build
```

## Community Guidelines

- Be respectful and inclusive
- Help others when possible
- Follow the code of conduct
- Report security issues privately

## Questions?

- Check existing issues and documentation
- Ask in discussions or create an issue
- Join community channels (if available)

## License

By contributing, you agree that your contributions will be licensed under the Mozilla Public License 2.0.
