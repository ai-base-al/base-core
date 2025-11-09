# BaseDev Tools

Automated tools for Base Browser development.

## sidepanel.sh - Side Panel Generator

Automatically generates all files needed for a new side panel and creates a patch file.

### Usage

```bash
./tools/sidepanel.sh <PanelName> [options]
```

### Options

- `--desc="description"` - Panel description
- `--side=left|right` - Side panel position (default: right)
- `--type=standard|custom` - Panel type (default: standard)

### Examples

```bash
# Create a Reading Mode panel (right side, standard type)
./tools/sidepanel.sh Reading --desc="Clean reading mode for articles"

# Create a Notes panel on the left side
./tools/sidepanel.sh Notes --desc="Quick note-taking" --side=left

# Create a custom Translate panel
./tools/sidepanel.sh Translate --desc="Translation" --type=custom

# Combine options
./tools/sidepanel.sh Tools --desc="Developer tools" --side=left --type=custom

# Legacy format still works
./tools/sidepanel.sh Reading "Clean reading mode"
```

### What It Generates

The script automatically creates:

1. **WebUI Backend** (`chrome/browser/ui/webui/side_panel/basedev_{feature}/`)
   - `{feature}_ui.h` - WebUI controller header
   - `{feature}_ui.cc` - WebUI controller implementation
   - `{feature}.mojom` - Mojo interface definition
   - `BUILD.gn` - Build configuration

2. **Coordinator** (`chrome/browser/ui/views/side_panel/`)
   - `basedev_{feature}_side_panel_coordinator.h` - Header
   - `basedev_{feature}_side_panel_coordinator.cc` - Implementation

3. **Frontend Resources** (`chrome/browser/resources/side_panel/basedev_{feature}/`)
   - `{feature}.html` - UI markup
   - `{feature}.css` - Styles
   - `{feature}.ts` - TypeScript logic
   - `BUILD.gn` - Resource build configuration

4. **Integration Changes**
   - Modifies `side_panel_entry.h` - Adds enum entry
   - Modifies `webui_url_constants.h` - Adds URL constants
   - Modifies `chrome_web_ui_controller_factory.cc` - Registers WebUI
   - Modifies `browser_view.cc` - Initializes coordinator

5. **Patch File**
   - Creates `patches/ungoogled-chromium/basedev-sidepanel-{feature}.patch`
   - Adds to `ungoogled-chromium/patches/series`

### Generated Naming Convention

For a panel named "Reading", the script generates:

| Item | Generated Name |
|------|----------------|
| Directory | `basedev_reading/` |
| Class | `BaseDevReadingModeUI` |
| Coordinator | `BaseDevReadingModeSidePanelCoordinator` |
| Enum ID | `kBaseDevReadingMode` |
| URL Host | `basedev-reading-side-panel` |
| URL | `chrome://basedev-reading-side-panel/` |
| Mojom Module | `basedev_reading.mojom` |
| Resource IDs | `IDS_BASEDEV_READING_MODE_*` |
| Patch File | `basedev-sidepanel-reading.patch` |

### Workflow

```bash
# 1. Generate the panel
./tools/sidepanel.sh Reading "Clean reading mode"

# 2. Review the generated patch
cat patches/ungoogled-chromium/basedev-sidepanel-reading.patch

# 3. Customize the implementation
# Edit the generated TypeScript, C++, and HTML files as needed

# 4. Build with the patch
./build/build.sh -d

# 5. Test your panel
# Navigate to chrome://basedev-reading-side-panel/
```

### Customization

After generation, you can customize:

1. **Frontend Logic** - Edit `chrome/browser/resources/side_panel/basedev_{feature}/{feature}.ts`
2. **UI Design** - Edit `chrome/browser/resources/side_panel/basedev_{feature}/{feature}.html` and `.css`
3. **Backend Logic** - Edit `chrome/browser/ui/webui/side_panel/basedev_{feature}/{feature}_ui.cc`
4. **Mojo Interface** - Edit `chrome/browser/ui/webui/side_panel/basedev_{feature}/{feature}.mojom`

After making changes, regenerate the patch:

```bash
cd ungoogled-chromium/build/src
git checkout -b feature/my-changes
git add -A
git diff main > ../../../patches/ungoogled-chromium/basedev-sidepanel-reading.patch
git checkout main
git branch -D feature/my-changes
```

### Requirements

- Chromium source must be extracted at `ungoogled-chromium/build/src`
- Git must be available
- Perl must be available (for file modifications)

### Output

The script provides detailed output showing:
- All generated files
- Modified files
- Patch file location and size
- Next steps for building and testing

### Limitations

- Currently supports side panels only
- Assumes standard Chromium source tree structure
- Requires manual refinement for complex features

### Troubleshooting

**Script fails with "Chromium source not found"**
- Run `./build/build.sh -d` first to extract source
- Or manually extract source to `ungoogled-chromium/build/src`

**Patch fails to apply**
- Source tree may have been modified
- Clean the source: `cd ungoogled-chromium/build && rm -rf src && mkdir src`
- Re-extract source and try again

**Build errors after applying patch**
- Review the generated code for syntax errors
- Check that all file paths are correct
- Verify BUILD.gn dependencies are complete

### See Also

- [SIDEPANEL.md](../guides/SIDEPANEL.md) - Complete side panel implementation guide
- [BASEDEV_NAMING.md](../guides/BASEDEV_NAMING.md) - Naming conventions
- [MAP.md](../MAP.md) - Repository structure
