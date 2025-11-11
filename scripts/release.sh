#!/bin/bash
set -e

# BaseOne Release Script
# Creates a complete release with DMG, git tag, and GitHub release

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/ungoogled-chromium/build/src"
OUT_DIR="$BUILD_DIR/out/Default"
BINARIES_DIR="$PROJECT_DIR/binaries"
RELEASES_DIR="$PROJECT_DIR/releases"

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
    -h, --help                  Show this help message

EXAMPLES:
    $0 -v 0.1.0 -c "Inception"
    $0 --version 0.1.0 --codename "Inception" --skip-build

REQUIREMENTS:
    - gh (GitHub CLI) must be installed and authenticated
    - BaseOne.app at: $BINARIES_DIR/BaseOne.app
    - Or run without --skip-build to build first

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

    # Check if tag already exists
    if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
        warn "Tag v${VERSION} already exists"
        read -p "Overwrite existing tag? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Tag creation cancelled"
        fi
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

    log "Pushing git tag to origin..."
    cd "$PROJECT_DIR"
    git push origin "v${VERSION}"
    log "Git tag pushed"
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
- Complete Base Dev branding
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

    # Create release
    log "Publishing release v${VERSION} to GitHub..."
    gh release create "v${VERSION}" \
        --title "$RELEASE_TITLE" \
        --notes "$RELEASE_NOTES" \
        "$DMG_PATH"

    log "GitHub release created successfully"
    log "View at: https://github.com/base-al/baseone/releases/tag/v${VERSION}"
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
    log "  Skip tag: $SKIP_TAG"
    log "  Skip GitHub: $SKIP_GITHUB"
    echo ""

    # Confirm
    read -p "Proceed with release? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Release cancelled"
        exit 0
    fi

    # Execute release steps
    build_browser
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
    log "  1. Check release: https://github.com/base-al/baseone/releases/tag/v${VERSION}"
    log "  2. Version API (one.base.al) will auto-update in ~5 minutes"
    log "  3. Test download and installation"
    echo ""
}

main "$@"
