# Base Core Releases

This document outlines the release process and version history for Base Core.

## Release Process

### Semantic Versioning

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **MAJOR**: Breaking changes or significant architecture updates
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Creating a Release

1. **Prepare the release:**
   ```bash
   # Update VERSION file
   echo "0.2.0" > VERSION

   # Update RELEASES.md with changes
   # Commit changes
   git add VERSION RELEASES.md
   git commit -m "Prepare release v0.2.0"
   ```

2. **Create and push tag:**
   ```bash
   git tag -a v0.2.0 -m "Release v0.2.0

   Summary of changes:
   - Feature 1
   - Feature 2
   - Bug fixes
   "

   git push origin main
   git push origin v0.2.0
   ```

3. **Build release:**
   ```bash
   npm run build
   # The .dmg will be in build/
   ```

4. **Create GitHub Release:**
   - Go to https://github.com/ai-base-al/base-core/releases/new
   - Select the tag (v0.2.0)
   - Add release notes
   - Upload the .dmg file
   - Publish release

### Branch Strategy

- **main** - Stable branch for releases
- **develop** - Development branch for ongoing work
- **feature/** - Feature branches
- **fix/** - Bug fix branches

### Development Workflow

```bash
# Start new feature
git checkout -b feature/my-feature main

# Make changes, commit
git add .
git commit -m "Add my feature"

# Push and create PR
git push origin feature/my-feature
# Create PR to main branch
```

## Version History

### v0.1.0 - 2025-11-04 (Initial GM)

**Initial Release** - Repository structure and build system setup

**Features:**
- Integrated ungoogled-chromium for macOS (arm64 & x86_64)
- brave-core inspired architecture
- Build system with `npm run build` commands
- Base browser branding and icons
- Privacy-focused configuration
- macOS signing and packaging scripts

**Structure:**
- `chromium_src/` - Custom Chromium file overrides
- `patches/` - Custom patches on top of ungoogled-chromium
- `ungoogled-chromium/` - Privacy patches and utilities
- `branding/` - Base browser icons and logos
- Build scripts for macOS development

**Configuration:**
- macOS 11.0+ (Big Sur or later)
- Apple Silicon (arm64) and Intel (x86_64) support
- Privacy-focused GN flags
- Disabled Google services

**Documentation:**
- README.md with quick start guide
- CONTRIBUTING.md with development guidelines
- Build troubleshooting and workflow

**Dependencies:**
- Xcode 12+
- Python 3, Ninja, Node.js
- Homebrew packages

This release establishes the foundation for Base browser development on macOS.

---

## Future Releases

### Planned for v0.2.0
- Custom UI modifications
- Base-specific features
- Enhanced privacy settings
- Custom new tab page

### Planned for v0.3.0
- Extension support improvements
- Additional branding integration
- Performance optimizations

---

## Release Notes Template

```markdown
### vX.Y.Z - YYYY-MM-DD

**Brief description**

**New Features:**
- Feature 1
- Feature 2

**Improvements:**
- Improvement 1
- Improvement 2

**Bug Fixes:**
- Fix 1
- Fix 2

**Breaking Changes:**
- Change 1 (if any)

**Known Issues:**
- Issue 1 (if any)
```
