#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VERSION_MANAGER_DIR="$SCRIPT_DIR/.."

echo "BaseOne Release Manager"
echo "======================="
echo ""

function show_usage() {
    echo "Usage: ./release.sh [patch|minor|major] [options]"
    echo ""
    echo "Version types:"
    echo "  patch    - Bug fixes (1.0.0 -> 1.0.1)"
    echo "  minor    - New features (1.0.0 -> 1.1.0)"
    echo "  major    - Breaking changes (1.0.0 -> 2.0.0)"
    echo ""
    echo "Options:"
    echo "  --codename=NAME          Set release codename"
    echo "  --chromium=142.0.0.0     Update Chromium base version"
    echo "  --notes=\"Release notes\"  Add release notes"
    echo "  --channel=stable         Set channel (stable|beta|dev|canary)"
    echo "  --no-build              Skip building the browser"
    echo "  --no-dmg                Skip creating DMG"
    echo "  --no-git                Skip git operations"
    echo ""
    echo "Examples:"
    echo "  ./release.sh patch"
    echo "  ./release.sh minor --codename=\"Horizon\" --notes=\"Added AI Assistant\""
    echo "  ./release.sh major --chromium=143.0.0.0 --channel=beta"
    echo ""
    exit 1
}

VERSION_TYPE="${1:-}"
if [[ "$VERSION_TYPE" != "patch" && "$VERSION_TYPE" != "minor" && "$VERSION_TYPE" != "major" ]]; then
    show_usage
fi

CODENAME=""
CHROMIUM_VERSION=""
RELEASE_NOTES=""
CHANNEL="stable"
DO_BUILD=true
DO_DMG=true
DO_GIT=true

shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --codename=*)
            CODENAME="${1#*=}"
            shift
            ;;
        --chromium=*)
            CHROMIUM_VERSION="${1#*=}"
            shift
            ;;
        --notes=*)
            RELEASE_NOTES="${1#*=}"
            shift
            ;;
        --channel=*)
            CHANNEL="${1#*=}"
            shift
            ;;
        --no-build)
            DO_BUILD=false
            shift
            ;;
        --no-dmg)
            DO_DMG=false
            shift
            ;;
        --no-git)
            DO_GIT=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
done

echo "Release Configuration:"
echo "  Version type: $VERSION_TYPE"
[[ -n "$CODENAME" ]] && echo "  Codename: $CODENAME"
[[ -n "$CHROMIUM_VERSION" ]] && echo "  Chromium base: $CHROMIUM_VERSION"
[[ -n "$RELEASE_NOTES" ]] && echo "  Notes: $RELEASE_NOTES"
echo "  Channel: $CHANNEL"
echo "  Build browser: $DO_BUILD"
echo "  Create DMG: $DO_DMG"
echo "  Git operations: $DO_GIT"
echo ""

read -p "Continue with release? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Release cancelled."
    exit 0
fi

echo ""
echo "Step 1: Bumping version..."
echo "-------------------------"

BUMP_CMD="node $SCRIPT_DIR/bump-version.js $VERSION_TYPE"
[[ -n "$CODENAME" ]] && BUMP_CMD="$BUMP_CMD --codename=$CODENAME"
[[ -n "$CHROMIUM_VERSION" ]] && BUMP_CMD="$BUMP_CMD --chromium=$CHROMIUM_VERSION"
[[ -n "$RELEASE_NOTES" ]] && BUMP_CMD="$BUMP_CMD --notes=$RELEASE_NOTES"
[[ -n "$CHANNEL" ]] && BUMP_CMD="$BUMP_CMD --channel=$CHANNEL"

eval $BUMP_CMD

NEW_VERSION=$(node -p "JSON.parse(require('fs').readFileSync('$VERSION_MANAGER_DIR/database/version.json')).current.version")
BUILD_NUMBER=$(node -p "JSON.parse(require('fs').readFileSync('$VERSION_MANAGER_DIR/database/version.json')).current.build_number")

echo ""
echo "New version: $NEW_VERSION (build $BUILD_NUMBER)"
echo ""

if [ "$DO_BUILD" = true ]; then
    echo "Step 2: Building BaseOne..."
    echo "-------------------------"

    if [ -f "$ROOT_DIR/base-core/scripts/6_build_incremental.sh" ]; then
        cd "$ROOT_DIR/base-core"
        ./scripts/6_build_incremental.sh
    elif [ -f "$ROOT_DIR/base-core/ungoogled-chromium/build.sh" ]; then
        cd "$ROOT_DIR/base-core/ungoogled-chromium"
        ./build.sh
    else
        echo "Error: Build script not found!"
        exit 1
    fi

    echo ""
    echo "Build completed!"
    echo ""
else
    echo "Step 2: Skipping build (--no-build)"
    echo ""
fi

if [ "$DO_DMG" = true ]; then
    echo "Step 3: Creating DMG..."
    echo "----------------------"

    DMG_NAME="BaseOne-$NEW_VERSION-macos-arm64.dmg"
    DMG_DIR="$ROOT_DIR/base-core/releases"
    mkdir -p "$DMG_DIR"

    APP_PATH="$ROOT_DIR/base-core/ungoogled-chromium/build/src/out/Default/BaseOne.app"

    if [ ! -d "$APP_PATH" ]; then
        echo "Error: BaseOne.app not found at $APP_PATH"
        exit 1
    fi

    if command -v create-dmg &> /dev/null; then
        create-dmg \
            --volname "BaseOne $NEW_VERSION" \
            --volicon "$APP_PATH/Contents/Resources/app.icns" \
            --window-pos 200 120 \
            --window-size 600 400 \
            --icon-size 100 \
            --icon "BaseOne.app" 175 190 \
            --hide-extension "BaseOne.app" \
            --app-drop-link 425 190 \
            "$DMG_DIR/$DMG_NAME" \
            "$APP_PATH"
    else
        echo "create-dmg not found, using hdiutil..."
        TMP_DMG="$DMG_DIR/tmp.dmg"
        hdiutil create -volname "BaseOne $NEW_VERSION" -srcfolder "$APP_PATH" -ov -format UDZO "$TMP_DMG"
        mv "$TMP_DMG" "$DMG_DIR/$DMG_NAME"
    fi

    echo ""
    echo "DMG created: $DMG_DIR/$DMG_NAME"
    echo ""
else
    echo "Step 3: Skipping DMG creation (--no-dmg)"
    echo ""
fi

if [ "$DO_GIT" = true ]; then
    echo "Step 4: Git operations..."
    echo "------------------------"

    cd "$ROOT_DIR/base-core"

    if [ ! -d ".git" ]; then
        echo "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit - BaseOne $NEW_VERSION"
    fi

    git add version-manager/database/version.json
    git commit -m "Release v$NEW_VERSION

Version: $NEW_VERSION
Build: $BUILD_NUMBER
Channel: $CHANNEL
${CODENAME:+Codename: $CODENAME}
${CHROMIUM_VERSION:+Chromium base: $CHROMIUM_VERSION}
${RELEASE_NOTES:+
$RELEASE_NOTES}"

    git tag -a "v$NEW_VERSION" -m "BaseOne v$NEW_VERSION"

    echo ""
    echo "Git tag created: v$NEW_VERSION"
    echo ""
    echo "To push to remote:"
    echo "  git remote add origin https://github.com/baseone/baseone.git"
    echo "  git push origin main"
    echo "  git push origin v$NEW_VERSION"
    echo ""
else
    echo "Step 4: Skipping git operations (--no-git)"
    echo ""
fi

echo "================================"
echo "Release $NEW_VERSION completed!"
echo "================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Test the build:"
echo "   open \"$ROOT_DIR/base-core/ungoogled-chromium/build/src/out/Default/BaseOne.app\""
echo ""

if [ "$DO_DMG" = true ]; then
    echo "2. Upload DMG to GitHub:"
    echo "   - Create release: https://github.com/baseone/releases/new"
    echo "   - Tag: v$NEW_VERSION"
    echo "   - Upload: $DMG_DIR/$DMG_NAME"
    echo ""
fi

if [ "$DO_GIT" = true ]; then
    echo "3. Push to git:"
    echo "   git push origin main"
    echo "   git push origin v$NEW_VERSION"
    echo ""
fi

echo "4. Deploy version API:"
echo "   - Commit version.json to version API repo"
echo "   - Or deploy to one.base.al"
echo ""
echo "5. Announce release!"
echo ""
