- always check @MAP.md to see where things are

## Base Browser Development Guidelines

### BaseDev Naming Convention
All custom features use the `basedev_` prefix to distinguish them from upstream Chromium:
- Patch files: `basedev-{category}-{feature}.patch`
- Directories: `basedev_{feature}/`
- C++ classes: `BaseDev{Feature}{Component}`
- Enum values: `kBaseDev{Feature}`
- URLs: `chrome://basedev-{feature}-{purpose}/`
- See `guides/BASEDEV_NAMING.md` for complete reference

### Development Tools

**Side Panel Generator**
Use `./tools/sidepanel.sh` to create new side panels:
```bash
./tools/sidepanel.sh <PanelName> ["description"]
```
This automatically generates:
- WebUI backend (C++, Mojo interface)
- Coordinator (panel lifecycle management)
- Frontend resources (HTML, CSS, TypeScript)
- Integration modifications
- Patch file in `patches/ungoogled-chromium/`
- See `tools/README.md` for details

### Development Guides
- `guides/SIDEPANEL.md` - Creating custom side panels (adapted for our setup)
- `guides/BASEDEV_NAMING.md` - Naming convention reference