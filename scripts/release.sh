#!/bin/bash
set -e

# BaseOne Release Script
# Creates a complete release with DMG, git tag, and GitHub release

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/ungoogled-chromium/build/src"
OUT_DIR="$BUILD_DIR/out/Default"
BINARIES_DIR="/Volumes/External/BaseChrome/baseone-binaries"
RELEASES_DIR="/Volumes/External/BaseChrome/baseone-binaries/releases"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
VERSION=""
CODENAME=""
CHROMIUM_VERSION="142.0.7444.134"
SKIP_BUILD=false
SKIP_TAG=false
SKIP_GITHUB=false
SKIP_SIGNING=false
SKIP_NOTARIZE=false
GITHUB_REPO="base-al/baseone"
SIGNING_IDENTITY="Developer ID Application: Basecode shpk (9FHBCA6NT3)"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Creates a complete BaseOne release with DMG, git tag, and GitHub release.

OPTIONS:
    -v, --version VERSION       Version number (e.g., 0.1.0) [REQUIRED]
    -c, --codename NAME         Release codename (e.g., "Inception")
    -m, --chromium VERSION      Chromium base version (default: $CHROMIUM_VERSION)
    -s, --skip-build            Skip building (use existing binary from binaries/)
    -n, --no-tag                Don't create git tag
    -g, --no-github             Don't create GitHub release
    --no-signing                Skip code signing (for testing only)
    --no-notarize               Skip notarization (sign only, faster for testing)
    -h, --help                  Show this help message

EXAMPLES:
    $0 -v 0.1.0 -c "Inception"
    $0 --version 0.1.0 --codename "Inception" --skip-build
    $0 --version 0.1.0 --skip-build --no-notarize

REQUIREMENTS:
    - gh (GitHub CLI) must be installed and authenticated
    - BaseOne.app at: $BINARIES_DIR/BaseOne.app
    - Or run without --skip-build to build first
    - Code signing certificate: $SIGNING_IDENTITY

EOF
    exit 1
}

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

check_requirements() {
    log "Checking requirements..."

    # Check gh CLI
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed. Install with: brew install gh"
    fi

    # Check gh authentication
    if ! gh auth status &> /dev/null; then
        error "GitHub CLI is not authenticated. Run: gh auth login"
    fi

    # Check version
    if [ -z "$VERSION" ]; then
        error "Version is required. Use -v or --version"
    fi

    # Validate version format (semver)
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Version must be in semver format (e.g., 0.1.0)"
    fi

    # Check for app in binaries directory
    if [ "$SKIP_BUILD" = true ]; then
        if [ ! -d "$BINARIES_DIR/BaseOne.app" ]; then
            error "BaseOne.app not found at: $BINARIES_DIR/BaseOne.app"
        fi
    fi

    log "Requirements check passed"
}

build_browser() {
    if [ "$SKIP_BUILD" = true ]; then
        log "Skipping build (--skip-build flag)"

        if [ ! -d "$BINARIES_DIR/BaseOne.app" ]; then
            error "BaseOne.app not found at: $BINARIES_DIR/BaseOne.app"
        fi

        return
    fi

    log "Building BaseOne browser..."
    cd "$BUILD_DIR"

    if ! ninja -C out/Default chrome; then
        error "Build failed"
    fi

    # Copy built app to binaries directory
    log "Copying built app to binaries directory..."
    mkdir -p "$BINARIES_DIR"
    cp -R "$OUT_DIR/BaseOne.app" "$BINARIES_DIR/"

    log "Build completed successfully"
}

sign_application() {
    if [ "$SKIP_SIGNING" = true ]; then
        log "Skipping code signing (--no-signing flag)"
        return
    fi

    log "Signing BaseOne.app with $SIGNING_IDENTITY..."

    local APP_PATH="$BINARIES_DIR/BaseOne.app"

    if [ ! -d "$APP_PATH" ]; then
        error "BaseOne.app not found at: $APP_PATH"
    fi

    # Sign all frameworks and helpers first (deep signing)
    log "Signing frameworks and helpers..."
    find "$APP_PATH" -type f \( -name "*.dylib" -o -name "*.framework" -o -name "*Helper*" \) -print0 | while IFS= read -r -d '' file; do
        codesign --force --sign "$SIGNING_IDENTITY" \
            --options runtime \
            --timestamp \
            "$file" 2>/dev/null || true
    done

    # Sign the main app bundle
    log "Signing main application bundle..."
    if ! codesign --force --deep --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        --entitlements "$PROJECT_DIR/ungoogled-chromium/entitlements/app.entitlements" \
        "$APP_PATH"; then
        error "Code signing failed"
    fi

    # Verify signature
    log "Verifying signature..."
    if ! codesign --verify --deep --strict --verbose=2 "$APP_PATH"; then
        error "Signature verification failed"
    fi

    log "Application signed successfully"
}

notarize_application() {
    if [ "$SKIP_SIGNING" = true ] || [ "$SKIP_NOTARIZE" = true ]; then
        if [ "$SKIP_NOTARIZE" = true ]; then
            log "Skipping notarization (--no-notarize flag)"
        fi
        return
    fi

    log "Notarizing application with Apple..."

    local APP_PATH="$BINARIES_DIR/BaseOne.app"
    local ZIP_PATH="$BINARIES_DIR/BaseOne.zip"

    # Create zip for notarization
    log "Creating archive for notarization..."
    rm -f "$ZIP_PATH"
    /usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

    # Submit for notarization
    log "Submitting to Apple notarization service..."
    if ! xcrun notarytool submit "$ZIP_PATH" \
        --keychain-profile "AC_PASSWORD" \
        --wait; then
        warn "Notarization failed or timed out"
        warn "You can continue without notarization for testing"
        read -p "Continue without notarization? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Release cancelled"
        fi
        rm -f "$ZIP_PATH"
        return
    fi

    # Staple the notarization ticket
    log "Stapling notarization ticket..."
    if ! xcrun stapler staple "$APP_PATH"; then
        warn "Failed to staple notarization ticket"
    fi

    # Cleanup
    rm -f "$ZIP_PATH"
    log "Notarization completed successfully"
}

create_dmg() {
    log "Creating DMG package..."

    mkdir -p "$RELEASES_DIR"

    local DMG_NAME="BaseOne-${VERSION}-macos-arm64.dmg"
    local DMG_PATH="$RELEASES_DIR/$DMG_NAME"
    local VOLUME_NAME="BaseOne $VERSION"

    # Remove old DMG if exists
    rm -f "$DMG_PATH"

    # Create temporary directory for DMG contents
    local TEMP_DIR=$(mktemp -d)
    cp -R "$BINARIES_DIR/BaseOne.app" "$TEMP_DIR/"

    # Create DMG
    log "Creating DMG: $DMG_NAME"
    hdiutil create -volname "$VOLUME_NAME" \
        -srcfolder "$TEMP_DIR" \
        -ov -format UDZO \
        "$DMG_PATH"

    # Cleanup
    rm -rf "$TEMP_DIR"

    # Get DMG size
    local DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
    log "DMG created: $DMG_PATH ($DMG_SIZE)"

    echo "$DMG_PATH"
}

create_git_tag() {
    if [ "$SKIP_TAG" = true ]; then
        log "Skipping git tag (--no-tag flag)"
        return
    fi

    log "Creating git tag v${VERSION}..."

    cd "$PROJECT_DIR"

    # Check if tag already exists and delete it automatically
    if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
        log "Tag v${VERSION} already exists, deleting it..."
        git tag -d "v${VERSION}"
    fi

    # Create annotated tag
    local TAG_MESSAGE="BaseOne ${VERSION}"
    if [ -n "$CODENAME" ]; then
        TAG_MESSAGE="$TAG_MESSAGE \"$CODENAME\""
    fi

    git tag -a "v${VERSION}" -m "$TAG_MESSAGE"
    log "Git tag v${VERSION} created"
}

push_git_tag() {
    if [ "$SKIP_TAG" = true ]; then
        return
    fi

    log "Skipping git tag push to base-core (release will create tag in ${GITHUB_REPO})..."
    # Note: gh release create will automatically create the tag in base-al/baseone
    # We keep local tags in base-core for tracking, but don't push them
}

create_github_release() {
    if [ "$SKIP_GITHUB" = true ]; then
        log "Skipping GitHub release (--no-github flag)"
        return
    fi

    local DMG_PATH="$1"

    log "Creating GitHub release..."

    cd "$PROJECT_DIR"

    # Build release notes
    local RELEASE_TITLE="BaseOne ${VERSION}"
    if [ -n "$CODENAME" ]; then
        RELEASE_TITLE="$RELEASE_TITLE \"$CODENAME\""
    fi

    local RELEASE_NOTES="## BaseOne ${VERSION}"
    if [ -n "$CODENAME" ]; then
        RELEASE_NOTES="${RELEASE_NOTES} \"${CODENAME}\""
    fi
    RELEASE_NOTES="${RELEASE_NOTES}

Codename: ${CODENAME:-Release}
Chromium: ${CHROMIUM_VERSION}

## What's New
- Complete BaseOne branding
- Privacy-focused features
- Enhanced security

## Download
- macOS ARM64 (Apple Silicon): BaseOne-${VERSION}-macos-arm64.dmg

## Installation
1. Download the DMG file
2. Open and drag BaseOne to Applications
3. Launch BaseOne from Applications

## System Requirements
- macOS 11.0 or later
- Apple Silicon (M1/M2/M3) or Intel processor
"

    # Check if release already exists and delete it automatically
    if gh release view "v${VERSION}" --repo "$GITHUB_REPO" >/dev/null 2>&1; then
        log "Release v${VERSION} already exists on GitHub, deleting it..."
        gh release delete "v${VERSION}" --repo "$GITHUB_REPO" --yes
    fi

    # Create release in base-al/baseone repository
    log "Publishing release v${VERSION} to ${GITHUB_REPO}..."
    gh release create "v${VERSION}" \
        --repo "$GITHUB_REPO" \
        --title "$RELEASE_TITLE" \
        --notes "$RELEASE_NOTES" \
        "$DMG_PATH"

    log "GitHub release created successfully"
    log "View at: https://github.com/${GITHUB_REPO}/releases/tag/v${VERSION}"
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -c|--codename)
                CODENAME="$2"
                shift 2
                ;;
            -m|--chromium)
                CHROMIUM_VERSION="$2"
                shift 2
                ;;
            -s|--skip-build)
                SKIP_BUILD=true
                shift
                ;;
            -n|--no-tag)
                SKIP_TAG=true
                shift
                ;;
            -g|--no-github)
                SKIP_GITHUB=true
                shift
                ;;
            --no-signing)
                SKIP_SIGNING=true
                shift
                ;;
            --no-notarize)
                SKIP_NOTARIZE=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    echo "=================================================="
    echo "         BaseOne Release Script"
    echo "=================================================="
    echo ""

    check_requirements

    log "Release configuration:"
    log "  Version: $VERSION"
    log "  Codename: ${CODENAME:-None}"
    log "  Chromium: $CHROMIUM_VERSION"
    log "  Skip build: $SKIP_BUILD"
    log "  Skip signing: $SKIP_SIGNING"
    log "  Skip notarize: $SKIP_NOTARIZE"
    log "  Skip tag: $SKIP_TAG"
    log "  Skip GitHub: $SKIP_GITHUB"
    echo ""

    # Execute release steps
    build_browser
    sign_application
    notarize_application
    DMG_PATH=$(create_dmg)
    create_git_tag
    push_git_tag
    create_github_release "$DMG_PATH"

    echo ""
    echo "=================================================="
    log "Release ${VERSION} completed successfully!"
    echo "=================================================="
    echo ""
    log "Next steps:"
    log "  1. Check release: https://github.com/${GITHUB_REPO}/releases/tag/v${VERSION}"
    log "  2. Version API (one.base.al) will auto-update in ~5 minutes"
    log "  3. Test download and installation"
    echo ""
}

main "$@"
