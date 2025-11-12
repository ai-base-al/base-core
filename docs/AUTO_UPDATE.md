# BaseOne Auto-Update System

Complete documentation for BaseOne's automatic update checking system using one.base.al API.

## Overview

BaseOne checks for updates automatically on startup and periodically, using the version API at https://one.base.al. This system:
- Uses our VERSION file (0.1.0) as the current version
- Checks one.base.al/api/version/check for updates
- Shows non-intrusive notification when update available
- Provides one-click download of new version

## Architecture

### Server-Side (Already Complete)
- API Server: `baseone-version-api/` (Node.js)
- Deployed at: https://one.base.al
- Endpoints:
  - `/api/version/current` - Latest version info
  - `/api/version/check?current=X.Y.Z` - Update check
  - `/api/version/history` - All releases
  - `/api/version/channels` - Release channels
- Automatically fetches from GitHub Releases
- 5-minute cache for performance

### Client-Side (To Implement)
- Update Checker: C++ service in browser
- Notification UI: Chrome infobar/notification
- Download Handler: Opens download page when user clicks

## Implementation Plan

### Phase 1: Version Reading
**File:** chrome/browser/baseone/version_info.h/cc

```cpp
// version_info.h
#ifndef CHROME_BROWSER_BASEONE_VERSION_INFO_H_
#define CHROME_BROWSER_BASEONE_VERSION_INFO_H_

#include <string>

namespace baseone {

// Returns BaseOne version (e.g., "0.1.0")
std::string GetVersion();

// Returns Chromium base version (e.g., "142.0.7444.134")
std::string GetChromiumVersion();

}  // namespace baseone

#endif  // CHROME_BROWSER_BASEONE_VERSION_INFO_H_
```

Version is read from VERSION file at build time and compiled into binary.

### Phase 2: Update Client
**File:** chrome/browser/baseone/update_client.h/cc

```cpp
// update_client.h
#ifndef CHROME_BROWSER_BASEONE_UPDATE_CLIENT_H_
#define CHROME_BROWSER_BASEONE_UPDATE_CLIENT_H_

#include <string>
#include "base/callback.h"
#include "url/gurl.h"

namespace baseone {

struct UpdateInfo {
  std::string current_version;
  std::string latest_version;
  bool update_available;
  std::string release_notes_url;
  std::string download_url;
};

class UpdateClient {
 public:
  using UpdateCheckCallback = base::OnceCallback<void(UpdateInfo)>;

  UpdateClient();
  ~UpdateClient();

  // Check for updates from one.base.al
  void CheckForUpdates(UpdateCheckCallback callback);

 private:
  const GURL kUpdateCheckUrl =
      GURL("https://one.base.al/api/version/check");

  void OnUpdateCheckComplete(UpdateCheckCallback callback,
                             const std::string& response);
};

}  // namespace baseone

#endif  // CHROME_BROWSER_BASEONE_UPDATE_CLIENT_H_
```

### Phase 3: Update Service
**File:** chrome/browser/baseone/update_service.h/cc

Manages update checking lifecycle:
- Checks on browser startup (after 30 seconds delay)
- Periodic checks (every 24 hours)
- Stores last check time in preferences
- Throttles checks to avoid excessive API calls

### Phase 4: Notification UI
**File:** chrome/browser/ui/baseone/update_infobar_delegate.h/cc

Shows infobar notification:
- Message: "BaseOne 0.2.0 is available"
- Buttons: "Download" and "Dismiss"
- Non-intrusive (can be dismissed)
- Shown once per update version

## API Integration

### Request Format
```
GET https://one.base.al/api/version/check?current=0.1.0
```

### Response Format
```json
{
  "current_version": "0.1.0",
  "latest_version": "0.2.0",
  "update_available": true,
  "release_notes_url": "https://github.com/base-al/baseone/releases/tag/v0.2.0",
  "download_url": "https://github.com/base-al/baseone/releases/download/v0.2.0/BaseOne-0.2.0-macos-arm64.dmg"
}
```

## Configuration

### Build-Time Configuration
Version is embedded at build time from VERSION file:

```bash
# In build system (GN)
defines = [
  "BASEONE_VERSION=\\"0.1.0\\"",
]
```

### Runtime Preferences
Stored in Chrome preferences (Local State):

```json
{
  "baseone": {
    "update": {
      "last_check_time": "2025-11-12T10:30:00Z",
      "dismissed_version": "0.2.0",
      "check_interval_hours": 24
    }
  }
}
```

## User Experience

### First-Time Check
1. User launches BaseOne
2. After 30 seconds, update check runs in background
3. If update available, infobar appears at top of window
4. User can download or dismiss

### Subsequent Checks
- Automatic check every 24 hours
- Manual check available in About page (future)
- Dismissed updates won't show again for that version

### Download Flow
1. User clicks "Download" button in infobar
2. Opens download page in new tab
3. User downloads and installs DMG
4. Browser shows "Relaunch to Update" option (future)

## Privacy & Security

### Privacy
- Only version numbers sent to API
- No user tracking or analytics
- No personal information collected
- Can be disabled via flag (future)

### Security
- HTTPS only (one.base.al)
- Download URLs verified (github.com)
- Signature verification of DMG (future)
- No automatic downloads (user consent required)

## Testing

### Local Testing
```bash
# Test with local API server
export BASEONE_UPDATE_URL="http://localhost:3000/api/version/check"

# Run browser
./out/Default/BaseOne.app/Contents/MacOS/BaseOne \
  --baseone-update-url=http://localhost:3000/api/version/check
```

### API Endpoint Testing
```bash
# Check current version
curl "https://one.base.al/api/version/current"

# Check for updates
curl "https://one.base.al/api/version/check?current=0.1.0"

# List all versions
curl "https://one.base.al/api/version/history"
```

## Deployment Workflow

### 1. Create New Release
```bash
# Update VERSION file
echo "0.2.0" > VERSION

# Build browser
./scripts/apply_base.sh
./scripts/build_incremental.sh

# Create release with scripts/release.sh
./scripts/release.sh -v 0.2.0 -c "Codename"
```

### 2. API Automatically Updates
- GitHub Release created with tag v0.2.0
- one.base.al fetches new version within 5 minutes
- Old browsers start receiving update notifications

### 3. Users Update
- Users see "BaseOne 0.2.0 available" notification
- Click "Download" to get new version
- Install and relaunch

## Command-Line Flags

### Update Configuration
```bash
# Disable update checking
--disable-baseone-updates

# Custom update URL (for testing)
--baseone-update-url=https://custom.example.com/api/check

# Force update check on startup
--force-baseone-update-check

# Skip initial delay
--skip-baseone-update-delay
```

## Future Enhancements

### Phase 2 Features
- In-browser update installer (macOS Sparkle-style)
- Background downloads
- Silent updates (with user consent)
- Rollback capability

### Phase 3 Features
- Update channels (stable, beta, dev, canary)
- Differential updates (smaller downloads)
- Update analytics (opt-in)
- Automatic update scheduling

## Troubleshooting

### No Update Notification Appears
1. Check preferences: `chrome://local-state` → baseone.update.last_check_time
2. Check network: `curl https://one.base.al/api/version/check?current=0.1.0`
3. Check console: Look for update_client errors
4. Force check: Restart with `--force-baseone-update-check`

### Update Check Fails
- Network connectivity issue
- API server down (check https://one.base.al/health)
- Firewall blocking HTTPS to one.base.al
- Check chrome://net-internals/#events for network errors

### Version Mismatch
- Ensure VERSION file matches built binary
- Rebuild after changing VERSION
- Clear cache: rm -rf out/Default
- Full rebuild if needed

## Related Documentation

- `/Volumes/External/BaseChrome/baseone-version-api/README.md` - API server docs
- `/Volumes/External/BaseChrome/baseone-version-api/DEPLOYMENT.md` - API deployment
- `/Volumes/External/BaseChrome/baseone-version-api/VERSIONING.md` - Version format
- `docs/BRANDING.md` - Version display in browser
- `scripts/README.md` - Build and release scripts

## Implementation Status

- [x] Server-side API (baseone-version-api) - Complete
- [x] API deployed at one.base.al - Complete
- [x] VERSION file created - Complete
- [ ] Version reading code (version_info.h/cc) - To implement
- [ ] Update client (update_client.h/cc) - To implement
- [ ] Update service (update_service.h/cc) - To implement
- [ ] Notification UI (update_infobar_delegate.h/cc) - To implement
- [ ] Integration with browser startup - To implement
- [ ] Preferences storage - To implement
- [ ] Command-line flags - To implement
- [ ] Testing and documentation - To implement

## Next Steps

1. Implement version_info module to read VERSION
2. Implement update_client to call API
3. Implement update_service for lifecycle management
4. Implement notification UI
5. Integrate with browser startup
6. Test end-to-end
7. Create patch and add to patches/series
8. Update documentation
