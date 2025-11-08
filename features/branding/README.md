# Branding Feature - "Base Dev"

Changes the browser name and icons from "Chromium" to "Base Dev".

## What This Changes

- **Product Name**: Chromium → Base Dev
- **Application Name**: Chromium.app → Base Dev.app
- **Window Title**: Shows "Base Dev" instead of "Chromium"
- **About Box**: Base Dev branding
- **Icons**: Custom Base Dev icons (blue/purple theme)

## Files Modified

- `chrome/app/theme/chromium/BRANDING` - Product name
- `chrome/app/chrome_exe.rc` - Windows resources
- `chrome/app/theme/chromium/mac/app.icns` - macOS app icon
- `chrome/app/theme/chromium/product_logo_*.png` - Product logos

## Usage

```bash
# Apply branding
./features/branding/apply.sh

# Build with new branding
cd ../..
./run/5_build_macos.sh -d

# Result: Base Dev.app in build/src/out/Default/
```

## Rollback

```bash
# Reset to original Chromium branding
./features/branding/rollback.sh
```

## Customization

Edit `config.sh` to change:
- Product name
- Short name
- Company name
- Colors (future)