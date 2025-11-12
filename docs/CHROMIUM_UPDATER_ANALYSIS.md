# Chromium Updater Analysis for BaseOne

Complete analysis of Chromium's chrome/updater system and implementation plan for BaseOne automatic updates.

## Executive Summary

**Recommendation: USE Chromium's chrome/updater system**

Chromium's updater (aka "Omaha 4") is:
- Fully present in our ungoogled-chromium source tree
- Explicitly designed for 3rd party customization (Microsoft Edge uses it)
- Already cross-platform (Windows, macOS, Linux)
- Production-ready with extensive testing infrastructure

**Implementation approach**: Modify branding configuration to point to https://one.base.al instead of Google's servers.

## Architecture Overview

### What is chrome/updater?

From chrome/updater/README.md:
```
The updater is built from a common, platform neutral code base, as part of
the Chrome build. The updater is a drop-in replacement for Google
Update/Omaha/Keystone and can be customized by 3rd party embedders to
update non-Google client software, such as Edge.
```

Key facts:
- **Mission**: Keep Chrome (and other software) up to date
- **Platforms**: Windows, macOS, Linux
- **Design**: Platform-neutral core + platform-specific implementations
- **Used by**: Chromium, Google Chrome, Microsoft Edge

### Component Structure

```
chrome/updater/
├── README.md                      # Overview and mission
├── BUILD.gn                       # Build configuration
├── branding.gni                   # Branding variables (UPDATE CHECK URL here!)
├── apply_updater_branding.gni     # Injects branding into templates
├── updater_branding.h.in          # Template for branding defines
│
├── configurator.h/cc              # Main configurator (uses ExternalConstants)
├── external_constants.h           # Abstract interface for constants
├── external_constants_default.cc  # Default implementation (uses UPDATE_CHECK_URL)
├── external_constants_override.cc # Runtime override (for testing only)
├── external_constants_builder.cc  # Builder for creating overrides
│
├── update_service.h               # Update service interface
├── update_service_impl_impl.cc    # Update service implementation
├── check_for_updates_task.h       # Background update checking
│
├── mac/                           # macOS-specific implementation
│   ├── setup/ks_tickets.h/mm     # Keystone ticket compatibility
│   └── install_from_archive.mm   # DMG installation
├── win/                           # Windows-specific implementation
├── linux/                         # Linux-specific implementation
│
├── test/                          # Integration tests
│   ├── server.h/cc               # Mock update server for testing
│   └── integration_tests.cc      # Full integration tests
│
└── tools/                         # Updater utilities
```

### Update URL Configuration Flow

```
1. branding.gni
   update_check_url = "https://omaha-qa.sandbox.google.com/service/update2/json"

2. apply_updater_branding.gni (line 60)
   "UPDATE_CHECK_URL=\"$update_check_url\""

3. updater_branding.h.in (line 24)
   #define UPDATE_CHECK_URL "@UPDATE_CHECK_URL@"
   (template variable @UPDATE_CHECK_URL@ replaced at build time)

4. external_constants_default.cc (line 40)
   std::vector<GURL> UpdateURL() const override {
     return std::vector<GURL>{GURL(UPDATE_CHECK_URL)};
   }

5. configurator.cc
   Uses external_constants_->UpdateURL() for all update checks
```

### Runtime Override Mechanism

The updater supports runtime overrides via `overrides.json` file for development/testing:

**Location**: `~/Library/Application Support/Chromium/ChromiumUpdater/overrides.json` (macOS)

**Example**:
```json
{
  "url": ["https://one.base.al/api/version/check"]
}
```

**Security Limitation** (external_constants_override.cc:61-66):
```cpp
// The test binary only ever needs to contact localhost during integration
// tests. To reduce the program's utility as a mule, crash if there is a
// non-localhost override.
CHECK(url.is_empty() || url.host() == "localhost" ||
      url.host() == "127.0.0.1" || url.host() == "not_exist")
    << "Illegal URL override: " << url;
```

This means **overrides.json cannot be used for production** - it will crash if the URL is not localhost.

For production, we must modify the build-time branding configuration.

## Current State Analysis

### ungoogled-chromium Status

Checked for updater-related patches:
```bash
grep -r "updater" /Volumes/External/BaseChrome/ungoogled-chromium/patches/
```

Result: Only 1 unrelated patch found (fix-disabling-safebrowsing.patch)

**Conclusion**: ungoogled-chromium has NOT disabled the updater. It's fully available.

### Current Branding Configuration

File: `chrome/updater/branding.gni` (lines 7-43)

For non-Chrome branded builds (`is_chrome_branded = false`):
```gni
browser_name = "Chromium"
browser_product_name = "Chromium"
updater_company_full_name = "Chromium Authors"
updater_company_short_name = "chromium"
updater_product_full_name = "ChromiumUpdater"
mac_updater_bundle_identifier = "org.chromium.ChromiumUpdater"
update_check_url = "https://omaha-qa.sandbox.google.com/service/update2/json"
updater_event_logging_url = "https://play.googleapis.com/staging/log/"
```

**What needs to change**:
- `update_check_url`: Change to `https://one.base.al/api/version/check`
- `updater_event_logging_url`: Change to empty or our own analytics endpoint
- Branding strings: Change to "BaseOne" equivalents
- Bundle identifiers: Change to `al.base.one.*` format

## Implementation Plan

### Phase 1: Update Branding Configuration

**Goal**: Modify chrome/updater/branding.gni to point to one.base.al

**File**: `/Volumes/External/BaseChrome/ungoogled-chromium/build/src/chrome/updater/branding.gni`

**Changes**:
```gni
# For non-Chrome branded builds
browser_name = "BaseOne"
browser_product_name = "BaseOne"
crash_product_name = "BaseOneUpdater"
crash_upload_url = ""  # Disable crash uploads or use our own
help_center_url = "https://basedev.al/help/"
app_logo_url = "https://one.base.al/assets/"
keystone_app_name = "BaseOneSoftwareUpdate"
keystone_bundle_identifier = "al.base.one.Keystone"
mac_browser_bundle_identifier = "al.base.one"
mac_updater_bundle_identifier = "al.base.one.Updater"
privileged_helper_bundle_name = "BaseOneUpdaterPrivilegedHelper"
privileged_helper_name = "al.base.one.UpdaterPrivilegedHelper"
updater_app_icon_path = "//chrome/app/theme/chromium/mac/app.icns"
updater_company_full_name = "BaseCode LLC"
updater_company_short_name = "BaseOne"
updater_company_short_name_lowercase = "baseone"
updater_company_short_name_uppercase = "BASEONE"
updater_copyright = "Copyright 2025 BaseCode LLC. All rights reserved."
updater_product_full_name = "BaseOneUpdater"
updater_product_full_name_dashed_lowercase = "baseone-updater"
updater_product_full_display_name = "BaseOne Updater"
updater_metainstaller_name = "BaseOne Installer"
mac_team_identifier = "YOUR_APPLE_TEAM_ID"  # TODO: Get from Apple Developer account

# CRITICAL: Update server URLs
update_check_url = "https://one.base.al/api/version/check"
updater_event_logging_url = ""  # Disable or use our own analytics

# App IDs (generate new GUIDs for BaseOne)
updater_appid = "{GENERATE-NEW-GUID-1}"
browser_appid = "{GENERATE-NEW-GUID-2}"
qualification_appid = "{GENERATE-NEW-GUID-3}"

# ... (rest stays same or adjusted)
```

**Create as patch**: `patches/baseone-updater-branding.patch`

### Phase 2: API Compatibility Check

**Goal**: Ensure one.base.al API matches Omaha protocol expectations

Chromium updater uses **Omaha Protocol** (see docs/updater/protocol_4.md).

**Current one.base.al API**:
```
GET /api/version/check?current=0.1.0

Response:
{
  "current_version": "0.1.0",
  "latest_version": "0.2.0",
  "update_available": true,
  "release_notes_url": "...",
  "download_url": "..."
}
```

**Omaha Protocol expects**:
```
POST /service/update2/json

Body: {
  "request": {
    "app": [{
      "appid": "{GUID}",
      "version": "0.1.0",
      ...
    }]
  }
}

Response: {
  "response": {
    "app": [{
      "updatecheck": {
        "status": "ok",
        "urls": { "url": [{"codebase": "..."}] },
        "manifest": {
          "version": "0.2.0",
          "packages": { "package": [{"name": "...", "hash_sha256": "..."}] }
        }
      }
    }]
  }
}
```

**Action required**: Modify baseone-version-api to support Omaha protocol format OR create an adapter layer.

**Options**:
1. **Extend one.base.al API** to support both current format and Omaha format
2. **Use Omaha format exclusively** (requires updating our API and documentation)
3. **Create adapter** in chrome/updater to convert between formats

**Recommendation**: Option 1 - extend API to support both formats for backward compatibility.

### Phase 3: Enable Updater in Build

**Goal**: Ensure chrome/updater is built and included in BaseOne

Check if updater is enabled in our build:
```bash
# Check GN args
grep -i "updater" out/Default/args.gn

# Check if updater target exists
gn desc out/Default //chrome/updater:updater
```

If not enabled, add to our build configuration:
```gn
# In args.gn or our branding patches
enable_updater = true
```

### Phase 4: Integration with Browser

**Goal**: Browser checks for updates on startup and periodically

The updater runs as a **separate process/service**, not embedded in the browser. Integration happens via:

1. **Browser startup** → Launches updater service (if not running)
2. **Updater service** → Periodically checks one.base.al for updates
3. **Update available** → Notifies browser
4. **Browser** → Shows update notification to user

**No additional integration needed** - this is built into Chromium.

### Phase 5: Testing

**Local Testing Setup**:

1. **Run local API server**:
   ```bash
   cd /Volumes/External/BaseChrome/baseone-version-api
   npm install
   npm start  # Runs on http://localhost:3000
   ```

2. **Test updater with local server** (using override):
   ```bash
   # Create override file (testing only)
   mkdir -p ~/Library/Application\ Support/BaseOne/BaseOneUpdater/
   cat > ~/Library/Application\ Support/BaseOne/BaseOneUpdater/overrides.json <<EOF
   {
     "url": ["http://localhost:3000/api/version/check"]
   }
   EOF

   # Run browser
   open BaseOne.app
   ```

3. **Monitor updater logs**:
   ```bash
   # macOS logs
   log stream --predicate 'process == "BaseOneUpdater"' --level debug
   ```

4. **Trigger manual update check**:
   ```bash
   # From chrome://help or via updater command
   ./BaseOne.app/Contents/Frameworks/BaseOneUpdater.app/Contents/MacOS/BaseOneUpdater --check-for-updates
   ```

## Protocol Comparison

### Our Current API vs Omaha Protocol

| Feature | Our API | Omaha Protocol |
|---------|---------|----------------|
| Method | GET | POST |
| Endpoint | /api/version/check?current=X.Y.Z | /service/update2/json |
| Request Format | Query params | JSON body with app metadata |
| App Identifier | None (implied) | Required GUID |
| Version Format | Semantic (X.Y.Z) | Same |
| Response | Simple JSON | Complex nested structure |
| Update URL | Direct download URL | Manifest with packages |
| Cryptographic Hash | Optional | Required (SHA256) |
| Differential Updates | No | Yes (patches supported) |

### Adapter Implementation (Option)

If we want to keep our simple API, we can create an adapter:

**File**: `chrome/updater/baseone_protocol_adapter.h/cc`

```cpp
// Converts Omaha protocol requests to BaseOne API format
class BaseOneProtocolAdapter {
 public:
  // Converts Omaha request to GET /api/version/check?current=X.Y.Z
  static GURL ConvertRequest(const base::Value::Dict& omaha_request);

  // Converts BaseOne API response to Omaha protocol response
  static base::Value::Dict ConvertResponse(const std::string& baseone_response);
};
```

This would be a thin adapter layer (100-200 lines) that sits between the updater and our API.

## Security Considerations

### Code Signing

The updater verifies downloaded updates using:
- **SHA256 hash** of the package
- **Code signature** verification (macOS/Windows)
- **CRX format** for update packages (optional)

**Required**:
1. Sign all BaseOne releases with Apple Developer ID
2. Include SHA256 hash in API response
3. Optionally: Package updates in CRX format for additional verification

### HTTPS Only

chrome/updater enforces HTTPS for all update checks (except localhost for testing).

Our server is already HTTPS: https://one.base.al

### No Auto-Install

By default, the updater:
- Downloads updates in background
- Notifies user
- **User must approve** installation

Auto-install requires user consent and is typically only used for security patches.

## Migration Path

### For Existing BaseOne Users

Current users have BaseOne 0.1.0 **without** the updater. When they install BaseOne 0.2.0 (first version with updater):

1. BaseOne 0.2.0 includes chrome/updater
2. On first launch, updater service installs itself
3. Updater begins checking for updates
4. Future updates (0.3.0+) can be installed via the updater

**No special migration needed** - updater installs itself on first launch.

### Keystone Migration (macOS)

Chromium's updater includes Keystone compatibility layer for migrating from Google's legacy Keystone updater:

- `chrome/updater/mac/setup/ks_tickets.h/mm`
- `chrome/updater/tools/keystone_ticketstore_tool.mm`

Since we're not migrating from Keystone, we can ignore this.

## Recommended Implementation

### Immediate (Weekend 1-2)

1. Create patch: `patches/baseone-updater-branding.patch`
   - Modify chrome/updater/branding.gni
   - Change update_check_url to https://one.base.al/api/version/check
   - Update all branding strings to BaseOne
   - Generate new GUIDs for app IDs

2. Extend baseone-version-api to support Omaha protocol
   - Add POST /service/update2/json endpoint
   - Keep GET /api/version/check for backward compatibility
   - Add SHA256 hash to responses

3. Test with local API server

### Short-term (Next Release)

1. Build BaseOne with updater enabled
2. Test end-to-end update flow
3. Deploy to staging environment
4. Beta test with select users

### Long-term (Future Releases)

1. Add support for update channels (stable, beta, dev)
2. Implement differential updates (smaller downloads)
3. Add usage statistics (opt-in)
4. Auto-update for security patches

## Files to Modify/Create

### Patches to Create

```
patches/baseone-updater-branding.patch
  - chrome/updater/branding.gni
  - Change all URLs and branding
  - ~100 lines changed

patches/baseone-updater-enable.patch (if needed)
  - Enable updater in build
  - May not be needed if already enabled
```

### API Changes (baseone-version-api)

```
/Volumes/External/BaseChrome/baseone-version-api/
  routes/omaha.js          # NEW: Omaha protocol endpoint
  routes/version.js        # MODIFY: Add SHA256 hash
  package.json             # MODIFY: Add crypto dependencies
  README.md                # UPDATE: Document Omaha endpoint
```

### Documentation

```
docs/AUTO_UPDATE.md                    # EXISTS: Implementation plan
docs/CHROMIUM_UPDATER_ANALYSIS.md      # THIS FILE: Complete analysis
baseone-version-api/OMAHA_PROTOCOL.md  # NEW: Omaha protocol spec
```

## Risks and Mitigations

### Risk 1: Protocol Mismatch
**Risk**: Our API doesn't match Omaha protocol expectations
**Mitigation**: Extend API to support both formats OR create adapter layer

### Risk 2: Code Signing Requirements
**Risk**: Unsigned updates will be rejected
**Mitigation**: Set up Apple Developer ID signing in release scripts

### Risk 3: Update Loop
**Risk**: Buggy update causes endless update/restart loop
**Mitigation**:
- Extensive testing before release
- Version checking prevents downgrade
- Manual override to disable updates

### Risk 4: Server Downtime
**Risk**: one.base.al unavailable, users can't update
**Mitigation**:
- High availability hosting
- CDN for API responses
- Graceful fallback (no update notification if server unreachable)

## Success Criteria

1. BaseOne automatically checks for updates on startup
2. Users receive notification when update available
3. One-click update download and install
4. Zero manual intervention for routine updates
5. Seamless experience (Chrome-like)

## References

### Chromium Documentation

Located in `/Volumes/External/BaseChrome/ungoogled-chromium/build/src/docs/updater/`:

- `design_doc.md` (54KB) - Architecture and design philosophy
- `functional_spec.md` (85KB) - Complete functional specification
- `dev_manual.md` (30KB) - Developer guide
- `protocol_4.md` (52KB) - Omaha Protocol 4 specification
- `user_manual.md` (13KB) - User-facing documentation

### Our Documentation

- `docs/AUTO_UPDATE.md` - Original implementation plan (simpler approach)
- `docs/CHROMIUM_UPDATER_ANALYSIS.md` - This file (complete analysis)
- `baseone-version-api/README.md` - Version API documentation

### External Resources

- Chromium Updater: https://chromium.googlesource.com/chromium/src/+/refs/heads/main/chrome/updater/
- Omaha Protocol: https://github.com/google/omaha/blob/main/doc/ServerProtocolV3.md
- Microsoft Edge Updater: Uses the same chrome/updater codebase

## Next Steps

1. Review this analysis with team
2. Decide on API compatibility approach (extend vs adapter)
3. Create branding patch
4. Test locally with mock server
5. Deploy and test end-to-end

**Estimated effort**: 2-4 days of development + 1-2 days of testing

**Complexity**: Medium (well-documented existing system, just needs reconfiguration)

**Confidence**: High (Edge successfully uses this, proven system)
