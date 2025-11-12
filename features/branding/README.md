# Branding Feature - "BaseOne"

Changes the browser name and icons from "Chromium" to "BaseOne".

## What This Changes

- **Product Name**: Chromium → BaseOne
- **Application Name**: Chromium.app → BaseOne.app
- **Window Title**: Shows "BaseOne" instead of "Chromium"
- **About Box**: BaseOne branding
- **Icons**: Custom BaseOne icons (blue/purple theme)

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

# Result: BaseOne.app in build/src/out/Default/
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