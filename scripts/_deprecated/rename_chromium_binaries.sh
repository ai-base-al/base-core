#!/bin/bash
# Rename all Chromium binaries to BaseOne

set -e

APP="/Volumes/External/BaseChrome/base-core/binaries/BaseOne.app"

echo "Renaming Chromium binaries to BaseOne..."

# Close BaseOne if running
killall "BaseOne" 2>/dev/null || true
sleep 2

cd "$APP/Contents"

# 1. Rename main executable
echo "1. Renaming main executable..."
mv MacOS/Chromium MacOS/BaseOne

# 2. Rename Framework
echo "2. Renaming Chromium Framework..."
mv "Frameworks/Chromium Framework.framework" "Frameworks/BaseOne Framework.framework"
mv "Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/Chromium Framework" "Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/BaseOne Framework"
mv "Frameworks/BaseOne Framework.framework/Chromium Framework" "Frameworks/BaseOne Framework.framework/BaseOne Framework"

# 3. Rename Helper apps
echo "3. Renaming Helper apps..."
cd "Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/Helpers"

mv "Chromium Helper.app" "BaseOne Helper.app"
mv "BaseOne Helper.app/Contents/MacOS/Chromium Helper" "BaseOne Helper.app/Contents/MacOS/BaseOne Helper"

mv "Chromium Helper (Renderer).app" "BaseOne Helper (Renderer).app"
mv "BaseOne Helper (Renderer).app/Contents/MacOS/Chromium Helper (Renderer)" "BaseOne Helper (Renderer).app/Contents/MacOS/BaseOne Helper (Renderer)"

mv "Chromium Helper (Plugin).app" "BaseOne Helper (Plugin).app"
mv "BaseOne Helper (Plugin).app/Contents/MacOS/Chromium Helper (Plugin)" "BaseOne Helper (Plugin).app/Contents/MacOS/BaseOne Helper (Plugin)"

mv "Chromium Helper (GPU).app" "BaseOne Helper (GPU).app"
mv "BaseOne Helper (GPU).app/Contents/MacOS/Chromium Helper (GPU)" "BaseOne Helper (GPU).app/Contents/MacOS/BaseOne Helper (GPU)"

mv "Chromium Helper (Alerts).app" "BaseOne Helper (Alerts).app"
mv "BaseOne Helper (Alerts).app/Contents/MacOS/Chromium Helper (Alerts)" "BaseOne Helper (Alerts).app/Contents/MacOS/BaseOne Helper (Alerts)"

# 4. Rename manifest
echo "4. Renaming manifest files..."
cd "$APP/Contents/Resources"
mv "org.chromium.Chromium.manifest" "al.base.one.manifest" || true
find . -name "org.chromium.Chromium.manifest" -exec rm -rf {} \; 2>/dev/null || true

# 5. Update Info.plist references
echo "5. Updating Info.plist..."
cd "$APP/Contents"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable 'BaseOne'" Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier al.base.one" Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleName 'BaseOne'" Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 'BaseOne'" Info.plist

# 6. Update Framework Info.plist
echo "6. Updating Framework Info.plist..."
FRAMEWORK_INFO="$APP/Contents/Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/Resources/Info.plist"
if [ -f "$FRAMEWORK_INFO" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable 'BaseOne Framework'" "$FRAMEWORK_INFO" || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier al.base.one.framework" "$FRAMEWORK_INFO" || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleName 'BaseOne Framework'" "$FRAMEWORK_INFO" || true
fi

# 7. Update Helper Info.plists
echo "7. Updating Helper Info.plists..."
HELPERS_DIR="$APP/Contents/Frameworks/BaseOne Framework.framework/Versions/142.0.7444.134/Helpers"

for helper in "BaseOne Helper" "BaseOne Helper (Renderer)" "BaseOne Helper (Plugin)" "BaseOne Helper (GPU)" "BaseOne Helper (Alerts)"; do
    HELPER_INFO="$HELPERS_DIR/$helper.app/Contents/Info.plist"
    if [ -f "$HELPER_INFO" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable '$helper'" "$HELPER_INFO" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier al.base.one.helper" "$HELPER_INFO" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Set :CFBundleName '$helper'" "$HELPER_INFO" 2>/dev/null || true
    fi
done

echo "Binary renaming complete!"
echo "BaseOne.app is ready"

# Touch the app to update timestamp
touch "$APP"

echo ""
echo "You can now open BaseOne.app"
