# Feature: Login with Base

## Metadata

- **Status**: Planning
- **Started**: 2025-11-09
- **Completed**: TBD
- **Category**: Core Feature | Authentication
- **Priority**: High
- **Contributors**: Development Team

## Overview

Implement "Login with Base" OAuth authentication to replace Google's removed OAuth system. Users can sign in with their accounts.base.al credentials, create local browser profiles, and sync settings across devices.

## Goals

- [ ] Implement OAuth 2.0 client for accounts.base.al
- [ ] Create local profile on successful login
- [ ] Restore Google OAuth UI patterns (but for Base)
- [ ] Store authentication tokens securely
- [ ] Support offline usage after initial login
- [ ] Optional settings sync (future)
- [ ] Profile management UI
- [ ] Secure token refresh mechanism

## Vision

Base Browser uses accounts.base.al (existing OAuth provider) for user authentication. This provides:
- **Single Sign-On**: One account across all Base services
- **Profile Management**: Local profiles tied to Base accounts
- **Privacy**: No Google tracking
- **Future Sync**: Settings and preferences sync (later)
- **Offline Work**: Full functionality after initial login

**Philosophy**: "Login when you want, work offline when you don't"

## Technical Approach

### Architecture

**OAuth 2.0 Flow**:
1. User clicks "Login with Base"
2. Browser opens accounts.base.al in auth flow
3. User authenticates
4. accounts.base.al redirects with auth code
5. Browser exchanges code for tokens
6. Create/load local profile for user
7. Store tokens securely
8. Refresh tokens as needed

**Profile Management**:
- Local profile per Base account
- Profile switching
- Multiple accounts support
- Guest/offline mode

### Research Required

**Find Google's OAuth Implementation** (removed by ungoogled-chromium):
- Need to examine vanilla Chromium source
- Understand profile creation on OAuth login
- Token storage mechanism
- UI integration points
- Profile sync infrastructure (optional)

**Key Areas to Research**:
```
chrome/browser/signin/                    # Sign-in infrastructure
chrome/browser/ui/webui/signin/           # Sign-in UI
components/signin/                        # Core signin components
google_apis/                              # Google OAuth (removed)
```

### Components

**OAuth Client**:
- OAuth 2.0 authorization flow
- Token exchange
- Token refresh
- Token storage (encrypted)

**Profile Manager Integration**:
- Create profile on login
- Associate profile with Base account
- Profile metadata (name, email, avatar)
- Profile switching

**UI Components**:
- Login button
- Profile menu
- Account switcher
- Settings integration

**Settings Sync** (Future):
- Sync preferences to Base servers
- Conflict resolution
- Selective sync
- Encryption

### Files to Create/Modify

```
chrome/browser/basedev/
├── signin/
│   ├── base_oauth_client.h/cc           # OAuth client
│   ├── base_token_manager.h/cc          # Token management
│   ├── base_profile_manager.h/cc        # Profile creation/management
│   └── BUILD.gn
├── sync/                                 # Future: settings sync
│   ├── base_sync_service.h/cc
│   └── BUILD.gn
└── BUILD.gn

chrome/browser/ui/webui/basedev/signin/
├── base_signin_ui.h/cc                   # Sign-in WebUI
├── base_signin_page_handler.h/cc
├── resources/
│   ├── signin.html                       # Login page
│   ├── signin.ts                         # Login logic
│   └── styles.css
└── BUILD.gn

chrome/browser/ui/views/profiles/
├── basedev_profile_menu.h/cc             # Profile menu UI
└── BUILD.gn

components/basedev/
├── oauth/
│   ├── oauth_constants.h                 # OAuth endpoints, client ID
│   ├── oauth_flow.h/cc                   # OAuth flow implementation
│   └── BUILD.gn
└── BUILD.gn
```

## Implementation Plan

### Phase 1: Research Google's OAuth (Vanilla Chromium)
- [ ] Clone vanilla Chromium source
- [ ] Study Google OAuth implementation
- [ ] Document profile creation flow
- [ ] Document token storage mechanism
- [ ] Identify ungoogled-chromium patches that removed OAuth
- [ ] Understand sync infrastructure

### Phase 2: OAuth Client Implementation
- [ ] Create Base OAuth client
- [ ] Implement authorization flow
- [ ] Implement token exchange
- [ ] Implement token refresh
- [ ] Secure token storage
- [ ] Test OAuth flow end-to-end

### Phase 3: Profile Integration
- [ ] Create profile on successful login
- [ ] Associate profile with Base account
- [ ] Store user metadata (name, email, avatar)
- [ ] Profile loading on browser startup
- [ ] Profile deletion

### Phase 4: UI Implementation
- [ ] Create "Login with Base" button
- [ ] Create login WebUI page
- [ ] Implement profile menu
- [ ] Account switcher UI
- [ ] Settings integration
- [ ] Avatar display

### Phase 5: Profile Management
- [ ] Multiple account support
- [ ] Profile switching
- [ ] Guest mode
- [ ] Sign out functionality
- [ ] Profile preferences

### Phase 6: Security & Polish
- [ ] Secure token encryption
- [ ] Token expiration handling
- [ ] Network error handling
- [ ] Offline mode
- [ ] Security audit

### Phase 7: Settings Sync (Future)
- [ ] Design sync protocol
- [ ] Implement sync service
- [ ] Settings serialization
- [ ] Conflict resolution
- [ ] Selective sync (user choice)
- [ ] Encryption in transit and at rest

## Progress Log

### 2025-11-09 - Planning
- Discussed Login with Base concept
- Identified need to research vanilla Chromium OAuth
- Decided on OAuth 2.0 with accounts.base.al
- Planned local profile creation
- Settings sync deferred to future
- Created feature plan document

## Challenges & Solutions

### Challenge 1: Finding Google's OAuth Code
**Problem**: ungoogled-chromium removed Google OAuth, need to understand original implementation

**Proposed Solution**:
- Clone vanilla Chromium at same version
- Compare with ungoogled-chromium to see what was removed
- Study chrome/browser/signin/ directory
- Document patterns to reimplement for Base

**Status**: Planning

### Challenge 2: Secure Token Storage
**Problem**: OAuth tokens are sensitive and must be stored securely

**Proposed Solution**:
- Use Chromium's existing secure storage (OSCrypt)
- Encrypt tokens at rest
- Store in user profile directory
- Never log tokens
- Clear on sign out

**Status**: Planning

### Challenge 3: Profile Creation Flow
**Problem**: Need to create browser profile after OAuth login

**Proposed Solution**:
- Study Chromium's profile manager
- Trigger profile creation on successful OAuth
- Populate profile with Base account data
- Migrate from guest profile if needed

**Status**: Planning

### Challenge 4: Offline Usage
**Problem**: Users should work offline after initial login

**Proposed Solution**:
- Local profile persists
- Tokens stored locally
- Refresh tokens when online
- Graceful degradation when offline
- No forced online checks

**Status**: Planning

## Technical Details

### OAuth 2.0 Configuration

**OAuth Endpoints** (accounts.base.al):
```
Authorization: https://accounts.base.al/oauth/authorize
Token:         https://accounts.base.al/oauth/token
UserInfo:      https://accounts.base.al/oauth/userinfo
```

**OAuth Scopes**:
- `profile`: User profile information (name, email, avatar)
- `settings.sync`: Settings sync (future)

**Client Configuration** (from build config):
```gn
# flags.macos.gn or build config
base_client_id = "base-browser-macos"
base_client_secret = "<secure secret>"
use_official_google_api_keys = false
```

### Token Storage

**Location**: `~/Library/Application Support/BaseOne/Default/Tokens`

**Format** (encrypted):
```json
{
  "access_token": "...",
  "refresh_token": "...",
  "expires_at": 1234567890,
  "user_info": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "User Name",
    "avatar_url": "https://..."
  }
}
```

### Profile Structure

**Profile Metadata**:
```
~/Library/Application Support/BaseOne/
├── Default/                              # Profile directory
│   ├── Preferences                       # Profile preferences
│   ├── Tokens                            # OAuth tokens (encrypted)
│   ├── avatar.png                        # User avatar
│   └── ...
├── Profile 1/                            # Additional profile
└── Guest/                                # Guest mode
```

### OAuth Flow Implementation

```cpp
// chrome/browser/basedev/signin/base_oauth_client.cc

class BaseOAuthClient {
 public:
  void StartAuthFlow() {
    // 1. Open accounts.base.al/oauth/authorize
    std::string auth_url = BuildAuthorizationURL();
    OpenInBrowser(auth_url);
  }

  void HandleCallback(const std::string& code) {
    // 2. Exchange code for tokens
    ExchangeCodeForTokens(code, base::BindOnce(
        &BaseOAuthClient::OnTokensReceived, base::Unretained(this)));
  }

  void OnTokensReceived(const OAuthTokens& tokens) {
    // 3. Store tokens securely
    token_manager_->StoreTokens(tokens);

    // 4. Fetch user info
    FetchUserInfo(tokens.access_token, base::BindOnce(
        &BaseOAuthClient::OnUserInfoReceived, base::Unretained(this)));
  }

  void OnUserInfoReceived(const UserInfo& user_info) {
    // 5. Create or load profile
    profile_manager_->CreateProfileForUser(user_info);

    // 6. Sign-in complete
    NotifySignInComplete(user_info);
  }

 private:
  std::unique_ptr<BaseTokenManager> token_manager_;
  ProfileManager* profile_manager_;
};
```

## Dependencies

**External Services**:
- accounts.base.al OAuth server
- Base API servers (for sync, future)

**Browser Components**:
- Chromium's profile system
- OSCrypt (secure storage)
- Network service
- WebUI framework

**Build Configuration**:
- OAuth client ID
- OAuth client secret
- API endpoints

## Integration Points

- **Profile System**: Create profiles on login
- **Settings**: OAuth settings page
- **UI**: Login button, profile menu
- **Network**: OAuth requests
- **Storage**: Secure token storage
- **Sync** (future): Settings sync to Base servers

## Testing

### Test Plan

**OAuth Flow**:
- [ ] Test authorization flow
- [ ] Test token exchange
- [ ] Test token refresh
- [ ] Test invalid credentials
- [ ] Test network errors
- [ ] Test token expiration

**Profile Management**:
- [ ] Test profile creation on login
- [ ] Test profile loading
- [ ] Test profile switching
- [ ] Test multiple accounts
- [ ] Test guest mode
- [ ] Test sign out (profile deletion optional)

**Security**:
- [ ] Test token encryption
- [ ] Test token storage security
- [ ] Test token not logged
- [ ] Test secure token transmission
- [ ] Test token refresh security

**Offline**:
- [ ] Test offline usage after login
- [ ] Test token refresh when back online
- [ ] Test graceful offline degradation

**UI**:
- [ ] Test login button appears
- [ ] Test login flow UI
- [ ] Test profile menu
- [ ] Test account switcher
- [ ] Test settings integration

### Test Results
- Status: Not started
- Coverage: 0%
- Issues found: None yet

## Documentation

### User Documentation
- Location: `docs/LOGIN.md` (to be created)
- Content:
  - How to sign in with Base account
  - Creating a Base account
  - Profile management
  - Sign out
  - Privacy and security

### Developer Documentation
- Location: `guides/LOGIN_DEV.md` (to be created)
- Content:
  - OAuth implementation details
  - Profile creation flow
  - Token management
  - Security considerations
  - Testing guide

## Related

### References
- [OAuth 2.0 Specification](https://oauth.net/2/)
- [Chromium Sign-in Architecture](https://chromium.googlesource.com/chromium/src/+/main/docs/signin.md)
- [Chrome Profile System](https://chromium.googlesource.com/chromium/src/+/main/docs/user_data_dir.md)

### Related Features
- Browser (ready)
- Code Editor (planned)
- AI Assistant (planned)
- Settings Sync (future)

## Outcomes

### Success Criteria
- Users can sign in with Base account
- Profile created and persisted
- Secure token storage
- Works offline after login
- Seamless profile switching
- No Google dependencies
- Privacy-focused

### Metrics
- Sign-in success rate: >99%
- Token refresh success rate: >99%
- Profile creation time: <2 seconds
- Offline functionality: 100%
- Security audit: Pass

## Next Steps

### Immediate Actions
1. **Research Phase**:
   - [ ] Clone vanilla Chromium (same version as ungoogled-chromium)
   - [ ] Study chrome/browser/signin/ implementation
   - [ ] Document Google OAuth patterns
   - [ ] Identify what ungoogled-chromium removed
   - [ ] Map OAuth flow to Base equivalent

2. **Design Phase**:
   - [ ] Design OAuth client architecture
   - [ ] Design token storage mechanism
   - [ ] Design profile creation flow
   - [ ] Design UI mockups

3. **Coordination**:
   - [ ] Confirm accounts.base.al OAuth endpoints
   - [ ] Obtain OAuth client credentials
   - [ ] Coordinate with Base account team

### Long-term
- [ ] Move to `progress/past/` when complete
- [ ] Implement settings sync
- [ ] Multi-device profile sync
- [ ] Enhanced profile features

## Notes

### Design Principles

1. **Privacy First**: No tracking, minimal data collection
2. **Offline Capable**: Work without internet after initial login
3. **Secure**: Encrypted tokens, secure transmission
4. **Simple**: One-click sign in
5. **Optional**: Not required to use browser

### OAuth vs Traditional Login

**Why OAuth?**
- Industry standard
- Secure token-based auth
- No password storage in browser
- Single sign-on across Base services
- Easy to revoke access
- Refresh tokens for persistence

### Comparison to Google Chrome

**Similar**:
- OAuth-based authentication
- Profile creation on login
- Profile switching
- Settings sync (future)

**Different**:
- Base account instead of Google account
- No forced online checks
- No tracking or analytics
- Privacy-focused
- Optional (not required)

### Settings Sync Considerations (Future)

**What to Sync**:
- Extensions and themes
- Bookmarks
- History (optional, user choice)
- Passwords (encrypted)
- Autofill data
- Preferences and settings

**What NOT to Sync**:
- Browsing data (unless user opts in)
- Cached files
- Session data
- Temporary data

**Sync Architecture**:
- End-to-end encrypted
- Base servers as sync backend
- Conflict resolution
- Selective sync
- Manual sync trigger
- Offline queue

## Questions to Resolve

- [ ] Final OAuth client ID and secret?
- [ ] OAuth endpoint URLs confirmed?
- [ ] Profile avatar storage strategy?
- [ ] Profile deletion on sign out?
- [ ] Settings sync priority and timeline?
- [ ] Multi-device support strategy?
- [ ] Account recovery flow?
- [ ] Email verification required?
- [ ] Two-factor authentication support?
- [ ] Session management strategy?

## Resources Needed

- OAuth client credentials from Base team
- Access to accounts.base.al API
- Vanilla Chromium source for research
- Security review resources
- Testing accounts on accounts.base.al
