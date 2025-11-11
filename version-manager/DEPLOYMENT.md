# BaseOne Deployment Guide

## Architecture

```
┌─────────────────┐
│  BaseOne Browser │
└────────┬────────┘
         │
         │ Check for updates
         ▼
┌─────────────────────────┐
│  one.base.al            │
│  (Version API)          │
│  Deployed on Caprover   │
└────────┬────────────────┘
         │
         │ Returns download URL
         ▼
┌─────────────────────────┐
│  GitHub Releases        │
│  (Browser Binaries)     │
│  github.com/baseone/... │
└─────────────────────────┘
```

## 1. Deploy Version API to Caprover

### Prerequisites
- Caprover server running
- Caprover CLI installed: `npm install -g caprover`

### Initial Setup

```bash
# Login to Caprover
caprover login

# Create app
caprover apps create one-base-al

# Enable HTTPS and custom domain
# In Caprover UI: Apps → one-base-al → HTTP Settings
# - Enable HTTPS
# - Add domain: one.base.al
```

### Deploy

```bash
cd version-manager

# Deploy
caprover deploy

# Or with specific app name
caprover deploy -a one-base-al
```

### Environment Variables (Optional)

In Caprover UI → Apps → one-base-al → App Configs:

```
PORT=3000
NODE_ENV=production
```

### Health Check

After deployment, test:

```bash
curl https://one.base.al/health
curl https://one.base.al/api/version/current
```

## 2. Store Binaries on GitHub Releases

### Create GitHub Repository

```bash
# Option 1: Create new repo
gh repo create baseone/baseone --public

# Option 2: Use existing repo
cd /path/to/baseone-repo
```

### Release Process

When you run `./scripts/release.sh`, it will:

1. Build the browser
2. Create DMG: `releases/BaseOne-1.0.0-macos-arm64.dmg`
3. Create git tag: `v1.0.0`
4. Commit and tag locally

Then manually create GitHub release:

```bash
# Push code and tags
git push origin main
git push origin v1.0.0

# Create GitHub release with DMG
gh release create v1.0.0 \
  releases/BaseOne-1.0.0-macos-arm64.dmg \
  --title "BaseOne 1.0.0" \
  --notes "Initial release with complete branding"
```

### Automated Release (Optional)

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Upload Release Asset
        uses: softprops/action-gh-release@v1
        with:
          files: releases/*.dmg
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 3. Update Version API

After creating GitHub release:

```bash
cd version-manager

# Update version.json (already done by release.sh)
# Commit and push
git add database/version.json
git commit -m "Update to v1.0.0"
git push

# Redeploy to Caprover
caprover deploy -a one-base-al
```

## Complete Release Workflow

### Step-by-step

```bash
# 1. Create new release
cd version-manager
./scripts/release.sh minor --codename="Velocity" --notes="Added AI Assistant"

# This creates:
# - releases/BaseOne-1.1.0-macos-arm64.dmg
# - Git tag v1.1.0
# - Updated version.json

# 2. Push to GitHub
git push origin main
git push origin v1.1.0

# 3. Create GitHub Release with DMG
gh release create v1.1.0 \
  releases/BaseOne-1.1.0-macos-arm64.dmg \
  --title "BaseOne 1.1.0 'Velocity'" \
  --notes "Added AI Assistant sidepanel"

# 4. Deploy updated version.json to Caprover
cd version-manager
caprover deploy -a one-base-al

# Done! Browser will now see update available
```

### Automated (Single Command)

Create `scripts/release-and-deploy.sh`:

```bash
#!/bin/bash

VERSION_TYPE=$1
shift

# 1. Create release
./scripts/release.sh $VERSION_TYPE "$@"

# 2. Get new version
NEW_VERSION=$(node -p "JSON.parse(require('fs').readFileSync('version-manager/database/version.json')).current.version")

# 3. Push to GitHub
git push origin main
git push origin "v$NEW_VERSION"

# 4. Create GitHub Release
gh release create "v$NEW_VERSION" \
  "releases/BaseOne-$NEW_VERSION-macos-arm64.dmg" \
  --title "BaseOne $NEW_VERSION" \
  --notes-file release-notes.txt

# 5. Deploy API
cd version-manager
caprover deploy -a one-base-al

echo "Release $NEW_VERSION deployed!"
```

## Monitoring

### Check API Status

```bash
curl https://one.base.al/health
```

### Check Current Version

```bash
curl https://one.base.al/api/version/current
```

### Test Update Check

```bash
curl "https://one.base.al/api/version/check?current=1.0.0"
```

### View Logs (Caprover)

```bash
caprover logs -a one-base-al --follow
```

## Costs

- **Caprover Server**: Your existing server (minimal resources needed)
- **GitHub Releases**: Free (unlimited storage and bandwidth)
- **Domain (one.base.al)**: Existing domain

**Total additional cost:** $0

## Security

### HTTPS

Caprover automatically handles Let's Encrypt SSL certificates for custom domains.

### CORS

The API allows all origins (`Access-Control-Allow-Origin: *`) which is fine for a public API.

### Rate Limiting (Optional)

Add to server.js if needed:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

## Troubleshooting

### API not responding

```bash
# Check Caprover logs
caprover logs -a one-base-al

# Restart app
caprover apps restart one-base-al
```

### Download URL not working

```bash
# Verify GitHub release exists
gh release view v1.0.0

# Check DMG was uploaded
gh release download v1.0.0 --pattern "*.dmg"
```

### Version not updating

```bash
# Verify version.json was updated
curl https://one.base.al/api/version/current

# Redeploy if needed
cd version-manager
caprover deploy -a one-base-al
```

## Migration to Cloudflare Workers (Future)

If you want to move to Cloudflare Workers later:

```bash
# Install Wrangler
npm install -g wrangler

# Create worker
cd version-manager
wrangler init

# Deploy
wrangler publish
```

Benefits:
- Global edge network
- Zero cold starts
- 100k requests/day free

But Caprover is great for now and gives you full control!
