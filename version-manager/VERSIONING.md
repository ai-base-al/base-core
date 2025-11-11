# BaseOne Versioning Strategy

## Decision: Semantic Versioning (Semver)

BaseOne uses **Semantic Versioning (semver)** instead of Chromium's 4-number versioning scheme.

### Chromium Versioning

Chromium uses: `MAJOR.MINOR.BUILD.PATCH`

Example: `142.0.7444.134`

- MAJOR: Increments with each major release (~4 weeks)
- MINOR: Usually 0
- BUILD: Internal build number
- PATCH: Patch releases

Problems for BaseOne:
- Confusing for users (what does 7444 mean?)
- Tied to Chromium's release schedule
- Not meaningful for our feature releases
- Difficult to communicate what changed

### BaseOne Versioning

BaseOne uses: `MAJOR.MINOR.PATCH` (Semantic Versioning)

Example: `1.0.0`

- MAJOR: Breaking changes or major features (1.0.0 -> 2.0.0)
- MINOR: New features, backward compatible (1.0.0 -> 1.1.0)
- PATCH: Bug fixes, minor updates (1.0.0 -> 1.0.1)

Benefits:
- Clear, user-friendly version numbers
- Meaningful: version tells you what changed
- Independent from Chromium release schedule
- Industry standard for most software
- Easy to communicate ("BaseOne 2.0 with AI Assistant!")

## Version Format

### User-Facing Version

Shown in About page and marketing:

```
BaseOne 1.0.0
```

Optional: Add codename for major releases:

```
BaseOne 1.0.0 "Foundation"
BaseOne 2.0.0 "Horizon"
```

### Technical Version String

Full version with Chromium base (for bug reports):

```
BaseOne 1.0.0 (based on Chromium 142.0.7444.134) (arm64)
```

Or shorter:

```
BaseOne 1.0.0 (Chromium 142) (arm64)
```

## Version Tracking

We maintain TWO version numbers:

1. **BaseOne Version**: `1.0.0` (semver, user-facing)
2. **Chromium Base**: `142.0.7444.134` (technical reference)

### In version.json:

```json
{
  "current": {
    "version": "1.0.0",              // BaseOne version (semver)
    "chromium_base": "142.0.7444.134", // Chromium base
    "build_number": 1,                // BaseOne build number
    "codename": "Foundation",
    "channel": "stable"
  }
}
```

## Release Channels

Like Chromium, BaseOne supports multiple channels:

- **Stable**: Production releases (1.0.0, 1.1.0, 2.0.0)
- **Beta**: Pre-release testing (1.1.0-beta.1)
- **Dev**: Development builds (1.2.0-dev.5)
- **Canary**: Nightly builds (1.3.0-canary.20251111)

## Version Bumping Examples

### Patch Release (Bug Fixes)

```bash
./scripts/release.sh patch --notes="Fixed bookmark sync crash"
```

Result: `1.0.0` -> `1.0.1`

### Minor Release (New Features)

```bash
./scripts/release.sh minor --codename="Velocity" --notes="Added AI Assistant sidepanel"
```

Result: `1.0.1` -> `1.1.0`

### Major Release (Breaking Changes)

```bash
./scripts/release.sh major --codename="Horizon" --notes="Complete UI redesign, new code editor"
```

Result: `1.1.0` -> `2.0.0`

### Chromium Base Update

```bash
./scripts/release.sh minor --chromium=143.0.0.0 --notes="Updated to Chromium 143"
```

Result: `1.1.0` -> `1.2.0`, Chromium base: `142.x.x.x` -> `143.0.0.0`

## Comparison: Chromium vs BaseOne

| Aspect | Chromium | BaseOne |
|--------|----------|---------|
| Format | 142.0.7444.134 | 1.0.0 |
| Versioning | 4-number | Semver |
| User-friendly | No | Yes |
| Release meaning | Unclear | Clear (major/minor/patch) |
| Independence | N/A | Independent from Chromium |
| Marketing | Difficult | Easy ("BaseOne 2.0!") |
| Technical info | Built-in | Separate field |

## Example Timeline

### Year 1

- Jan 2025: **BaseOne 1.0.0 "Foundation"** (Chromium 142)
  - Initial release with complete branding

- Feb 2025: **BaseOne 1.0.1** (Chromium 142)
  - Bug fixes for initial release

- Mar 2025: **BaseOne 1.1.0 "Explorer"** (Chromium 143)
  - Added Reading Mode sidepanel
  - Updated Chromium base to 143

- May 2025: **BaseOne 1.2.0 "Assistant"** (Chromium 144)
  - Added AI Assistant with MCP support
  - Updated Chromium base to 144

- Jul 2025: **BaseOne 2.0.0 "Coder"** (Chromium 145)
  - Added integrated Code Editor
  - Major UI refresh
  - Updated Chromium base to 145

### Marketing Examples

Easy to communicate:

- "BaseOne 1.0 launches today!"
- "BaseOne 1.1 adds AI-powered reading mode"
- "BaseOne 2.0: Now with built-in code editor"

vs. Chromium-style:

- "BaseOne 142.0.7444.134 launches today!" (confusing)
- "BaseOne 143.0.7520.89 adds reading mode" (what?)
- "BaseOne 145.0.7800.42 has code editor" (huh?)

## Implementation

### 1. Browser displays BaseOne version

In `chrome://settings/help`:

```
BaseOne
Version 1.0.0

Based on Chromium 142.0.7444.134
Copyright 2025 BaseCode LLC
```

### 2. User agent string

```
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) BaseOne/1.0.0 Chrome/142.0.7444.134 Safari/537.36
```

### 3. Update checks

Browser queries: `https://one.base.al/api/version/check?current=1.0.0`

Response:

```json
{
  "current_version": "1.0.0",
  "latest_version": "1.1.0",
  "update_available": true,
  "download_url": "https://github.com/baseone/releases/download/v1.1.0/BaseOne-1.1.0-macos-arm64.dmg"
}
```

## Summary

BaseOne uses **Semantic Versioning (1.0.0)** for user-facing versions while maintaining a reference to the **Chromium base version (142.0.7444.134)** for technical purposes.

This approach provides:
- Clear, meaningful version numbers for users
- Independent release schedule from Chromium
- Better marketing and communication
- Industry-standard versioning practice
- Technical traceability to Chromium base

Best of both worlds!
