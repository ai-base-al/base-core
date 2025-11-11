# BaseOne Version Manager

Simple version management API for BaseOne browser. Hosts on one.base.al to provide version information and update checks.

## Features

- RESTful API for version information
- Version history tracking
- Update availability checks
- Multiple release channels (stable, beta, dev, canary)
- Simple version bumping scripts

## Directory Structure

```
version-manager/
├── api/
│   └── server.js           # API server
├── database/
│   └── version.json        # Version database
├── scripts/
│   └── bump-version.js     # Version bumping script
├── package.json
└── README.md
```

## API Endpoints

### GET /api/version/current

Returns current version information:

```json
{
  "version": "1.0.0",
  "codename": "Foundation",
  "release_date": "2025-11-11",
  "chromium_base": "142.0.7444.134",
  "build_number": 1,
  "channel": "stable",
  "download_url": "https://github.com/baseone/releases/download/v1.0.0/BaseOne-1.0.0-macos-arm64.dmg"
}
```

### GET /api/version/check?current=1.0.0

Check if update is available:

```json
{
  "current_version": "1.0.0",
  "latest_version": "1.1.0",
  "update_available": true,
  "release_notes_url": "https://github.com/baseone/releases/tag/v1.1.0",
  "download_url": "https://github.com/baseone/releases/download/v1.1.0/BaseOne-1.1.0-macos-arm64.dmg"
}
```

### GET /api/version/history

Returns version history:

```json
{
  "history": [
    {
      "version": "1.0.0",
      "codename": "Foundation",
      "release_date": "2025-11-11",
      "chromium_base": "142.0.7444.134",
      "build_number": 1,
      "channel": "stable",
      "notes": "Initial BaseOne release"
    }
  ]
}
```

### GET /api/version/channels

Returns all release channels:

```json
{
  "channels": {
    "stable": "1.0.0",
    "beta": null,
    "dev": null,
    "canary": null
  }
}
```

## Usage

### Running the Server

```bash
# Development
npm run dev

# Production
npm start

# Or with custom port
PORT=8080 npm start
```

The server will run on port 3000 by default (or PORT environment variable).

### Bumping Versions

```bash
# Bump patch version (1.0.0 -> 1.0.1)
npm run bump:patch

# Bump minor version (1.0.0 -> 1.1.0)
npm run bump:minor

# Bump major version (1.0.0 -> 2.0.0)
npm run bump:major

# With custom options
node scripts/bump-version.js minor --codename="Horizon" --chromium=143.0.0.0 --notes="Added new features"
```

### Version Bump Options

- `--codename=Name`: Set release codename
- `--chromium=142.0.0.0`: Update Chromium base version
- `--notes=Text`: Add release notes
- `--channel=stable|beta|dev|canary`: Set release channel

## Deployment to one.base.al

### Option 1: Static Hosting (GitHub Pages)

Since the API only serves JSON files, you can use GitHub Pages:

1. Create a GitHub repository: `baseone/version-api`
2. Enable GitHub Pages
3. Configure custom domain: `one.base.al`
4. Use client-side fetching

### Option 2: Serverless (Cloudflare Workers)

Deploy to Cloudflare Workers for dynamic API:

```bash
# Install Wrangler CLI
npm install -g wrangler

# Deploy
wrangler deploy
```

### Option 3: Simple Node.js Server

Deploy to any Node.js hosting (Vercel, Railway, etc.):

```bash
# Deploy to Vercel
vercel deploy

# Or Railway
railway up
```

### Option 4: Static JSON Files

Simplest approach - just commit version.json and serve it:

```
https://one.base.al/version.json
```

## Integration with BaseOne Browser

The browser will check for updates on startup:

```cpp
// In BaseOne source
const std::string kVersionCheckUrl = "https://one.base.al/api/version/check";

void CheckForUpdates() {
  std::string current_version = GetCurrentVersion(); // "1.0.0"
  std::string url = kVersionCheckUrl + "?current=" + current_version;

  // Fetch and parse JSON response
  // Show update notification if available
}
```

## Version Format

BaseOne uses semantic versioning:

- **Major**: Breaking changes or major features (1.0.0 -> 2.0.0)
- **Minor**: New features, backward compatible (1.0.0 -> 1.1.0)
- **Patch**: Bug fixes, minor updates (1.0.0 -> 1.0.1)

## Example Workflow

1. **Make changes to BaseOne**
2. **Bump version**: `npm run bump:minor --notes="Added AI Assistant"`
3. **Build and test**
4. **Create GitHub release**: Tag as `v1.1.0`
5. **Upload DMG**: `BaseOne-1.1.0-macos-arm64.dmg`
6. **Push version.json**: Updates API automatically
7. **Users get update notification**: On next launch

## License

MIT
