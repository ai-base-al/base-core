# Feature: Integrated Code Editor

## Metadata

- **Status**: MVP Implemented
- **Started**: 2025-11-09
- **MVP Completed**: 2025-11-10
- **Completed**: TBD (full feature set)
- **Category**: Core Feature | Code Editor
- **Priority**: Critical
- **Contributors**: Development Team

## Overview

Create an integrated code editor within Base Browser, making it a 3-in-1 application: Browser + Code Editor + AI Assistant. The code editor will be a custom tab type with Monaco Editor, file explorer, terminal, and AI assistant integration.

## Goals

- [ ] Implement custom tab type for code editor (chrome://code/)
- [ ] Integrate Monaco Editor with LSP support
- [ ] Create file explorer sidepanel (left side)
- [ ] Integrate terminal with real system shell access
- [ ] Connect AI assistant to code editor context
- [ ] Implement trusted folder access (VS Code-style)
- [ ] Ensure offline functionality after initial setup
- [ ] Match VS Code's proven UX patterns

## Vision

Base Browser is not just a browser - it's a 3-in-1 application:
1. **Browser** (ready - based on Chromium)
2. **Code Editor** (this feature)
3. **AI Assistant** (sidepanel integration)

The code editor brings development capabilities directly into the browser, eliminating the need to switch between applications.

## Technical Approach

### Architecture

**Custom Tab Type**: Create a specialized tab type distinct from regular browser tabs:
- URL: `chrome://code/`
- No address bar
- Custom UI with dedicated sidepanels
- Different behavior and lifecycle from browser tabs

**Technology Stack**:
- **Editor**: Monaco Editor (VS Code's editor component)
  - Open source and embeddable
  - Built-in LSP (Language Server Protocol) support
  - Proven technology used in VS Code
- **File Access**: File System Access API with trusted folders
  - User grants access once, remembered like VS Code
  - Persistent permissions across sessions
- **Terminal**: Real system shell integration
  - Full shell access (not sandboxed)
  - Matches VS Code's terminal behavior
  - Runs actual system commands

**Philosophy**: "We don't want to reinvent much here, VS Code has already done it" - leverage proven patterns and technologies.

### Components

**Custom Tab Infrastructure**:
- Custom tab type registration
- Tab lifecycle management
- Custom UI chrome (no address bar)
- Sidepanel attachment system

**Editor Component**:
- Monaco Editor integration
- Language Server Protocol setup
- Syntax highlighting
- Code intelligence (autocomplete, go-to-definition, etc.)
- Multi-file editing support

**File Explorer Sidepanel** (Left):
- Directory tree view
- File operations (create, rename, delete, move)
- Trusted folder management
- File type icons
- Search functionality

**Terminal Integration** (Center-Bottom):
- Real system shell (bash/zsh on macOS)
- Full terminal emulation
- Command execution
- Output streaming
- Terminal tabs/splits

**AI Assistant Integration** (Right):
- Code-context aware
- Can read open files
- Suggest improvements
- Explain code
- Debug assistance

### Files to Create/Modify

```
chrome/browser/ui/views/tabs/
├── basedev_code_tab.h                    # Custom tab type definition
├── basedev_code_tab.cc                   # Implementation
└── basedev_code_tab_controller.h/cc      # Tab controller

chrome/browser/ui/webui/basedev/
├── code_editor/
│   ├── code_editor_ui.h/cc              # WebUI page handler
│   ├── code_editor_page_handler.h/cc    # Backend logic
│   ├── resources/
│   │   ├── index.html                   # Main editor page
│   │   ├── editor.ts                    # Monaco integration
│   │   ├── file_explorer.ts             # File tree
│   │   ├── terminal.ts                  # Terminal component
│   │   └── styles.css                   # Styling
│   └── BUILD.gn                         # Build configuration

chrome/browser/ui/views/side_panel/basedev/
├── file_explorer_panel.h/cc             # File explorer sidepanel
└── file_explorer_coordinator.h/cc       # Coordinator

components/basedev/
├── file_access/                         # File system integration
├── terminal/                            # Terminal backend
└── BUILD.gn

third_party/monaco-editor/               # Monaco Editor dependency
```

## Implementation Plan

### Phase 1: Custom Tab Type Foundation
- [ ] Research Chromium's tab type system
- [ ] Create custom tab type registration
- [ ] Implement basic tab lifecycle (open, close, switch)
- [ ] Remove address bar for code editor tabs
- [ ] Add tab icon and title customization
- [ ] Test tab type in isolation

### Phase 2: Monaco Editor Integration
- [ ] Add Monaco Editor to third_party/
- [ ] Create WebUI page for code editor
- [ ] Integrate Monaco Editor into WebUI
- [ ] Implement basic text editing
- [ ] Add syntax highlighting
- [ ] Configure LSP support
- [ ] Test with multiple programming languages

### Phase 3: File System Access
- [ ] Implement File System Access API integration
- [ ] Create trusted folder permission system
- [ ] Implement folder selection dialog
- [ ] Store trusted folder paths in profile
- [ ] Add permission revocation
- [ ] Test read/write operations
- [ ] Handle permission errors gracefully

### Phase 4: File Explorer Sidepanel
- [ ] Create file explorer sidepanel (left side)
- [ ] Implement directory tree view
- [ ] Add file operations (CRUD)
- [ ] Add file type icons
- [ ] Implement file search
- [ ] Connect to opened files in editor
- [ ] Add context menus
- [ ] Test with large directories

### Phase 5: Terminal Integration
- [ ] Research terminal emulation options
- [ ] Create terminal backend (C++ process spawning)
- [ ] Implement WebUI terminal component
- [ ] Connect frontend to backend via Mojo
- [ ] Add terminal output streaming
- [ ] Implement input handling
- [ ] Add terminal tabs/splits
- [ ] Test with various shell commands

### Phase 6: AI Assistant Integration
- [ ] Connect AI assistant to code editor tab
- [ ] Implement code context awareness
- [ ] Add "explain code" feature
- [ ] Add "suggest improvements" feature
- [ ] Implement inline suggestions
- [ ] Test AI integration workflow

### Phase 7: Polish & Features
- [ ] Add keyboard shortcuts (VS Code compatible)
- [ ] Implement multi-file editing (tabs)
- [ ] Add split editor views
- [ ] Implement find/replace
- [ ] Add git integration (optional)
- [ ] Theme support (light/dark)
- [ ] Settings persistence
- [ ] Performance optimization

### Phase 8: Testing & Documentation
- [ ] Unit tests for all components
- [ ] Integration tests
- [ ] Performance testing
- [ ] Security review (file access, terminal)
- [ ] User documentation
- [ ] Developer documentation

## Progress Log

### 2025-11-10 - MVP Implementation
**Implemented**:
- Created chrome://code/ WebUI page (BaseDevCodeUI + BaseDevCodeUIConfig)
- Integrated Monaco Editor from CDN (v0.45.0)
- Implemented file explorer UI with File System Access API
- Created multi-tab file editing interface
- Built integrated terminal with command execution
- Added VS Code-inspired dark theme
- Implemented keyboard shortcuts (Cmd/Ctrl + S, O, N, `)
- Created welcome screen with feature highlights
- Added file operations (open, save, new file)
- Implemented basic terminal commands (help, ls, pwd, echo, clear)

**Components Created**:
- `chrome/browser/ui/webui/basedev_code/basedev_code_ui.h/cc` (WebUI backend)
- `chrome/browser/resources/basedev_code/index.html` (Main UI)
- `chrome/browser/resources/basedev_code/editor.css` (Styling)
- `chrome/browser/resources/basedev_code/editor.js` (Editor logic)
- `chrome/browser/resources/basedev_code/BUILD.gn` (Resources)
- `chrome/browser/resources/basedev_code/basedev_code_resources.grd` (Resources manifest)
- `chrome/browser/ui/webui/basedev_code/BUILD.gn` (Backend build)

**Integration**:
- Registered chrome://code/ URL in `webui_url_constants.h`
- Added config to `chrome_web_ui_configs.cc`
- Updated `chrome/browser/ui/webui/BUILD.gn`
- Updated `chrome/browser/resources/BUILD.gn`
- Created patch file `patches/ungoogled-chromium/basedev-code-editor-monaco.patch`
- Added to `patches/series`

**Status**: MVP complete but untested (needs build to verify)

### 2025-11-09 - Planning & Vision
- Discussed overall vision for Base Browser (3-in-1)
- Established technology stack (Monaco, trusted folders, real shell)
- Decided on custom tab type approach (no address bar)
- Defined philosophy: leverage VS Code patterns
- Created feature plan document

## Challenges & Solutions

### Challenge 1: Tab Type Customization
**Problem**: Need custom tab type without address bar, different from browser tabs

**Proposed Solution**:
- Create dedicated tab type class (basedev_code_tab)
- Override UI rendering to exclude address bar
- Implement custom tab strip appearance

**Status**: Planning

### Challenge 2: Monaco Editor Integration
**Problem**: Need to bundle and integrate Monaco Editor into Chromium

**Proposed Solution**:
- Add Monaco to third_party/ as external dependency
- Use WebUI to host editor (HTML/JS/CSS)
- Bridge between C++ backend and Monaco frontend via Mojo

**Status**: Planning

### Challenge 3: File System Access Security
**Problem**: Need secure file access without compromising browser security

**Proposed Solution**:
- Use File System Access API (trusted folders pattern)
- User explicitly grants access (like VS Code)
- Store permissions in user profile
- Sandboxed file operations through Chromium APIs

**Status**: Planning

### Challenge 4: Terminal Security
**Problem**: Real shell access is powerful but potentially dangerous

**Proposed Solution**:
- Run terminal in separate process
- User awareness: clearly indicate this is a real terminal
- Use same security model as VS Code
- Only available in code editor tab (isolated from browser tabs)

**Status**: Planning

## Technical Details

### Custom Tab Type Implementation

**Tab Registration**:
```cpp
// chrome/browser/ui/views/tabs/basedev_code_tab.h
class BaseDevCodeTab : public Tab {
 public:
  BaseDevCodeTab();
  ~BaseDevCodeTab() override;

  // Override Tab methods
  bool ShouldShowAddressBar() override { return false; }
  bool IsCodeEditorTab() override { return true; }

 private:
  // Custom tab logic
};
```

**URL Registration**:
```cpp
// chrome/common/webui_url_constants.h
inline constexpr char kChromeUICodeEditorHost[] = "code";
inline constexpr char kChromeUICodeEditorURL[] = "chrome://code/";
```

### Monaco Editor Integration

**WebUI Setup**:
```typescript
// chrome/browser/ui/webui/basedev/code_editor/resources/editor.ts
import * as monaco from 'monaco-editor';

export class CodeEditor {
  private editor: monaco.editor.IStandaloneCodeEditor;

  constructor(container: HTMLElement) {
    this.editor = monaco.editor.create(container, {
      language: 'typescript',
      theme: 'vs-dark',
      automaticLayout: true,
    });
  }

  async openFile(path: string) {
    // Load file content via Mojo IPC
    const content = await this.pageHandler.readFile(path);
    this.editor.setValue(content);
  }
}
```

### File Access Pattern

**Trusted Folders**:
```cpp
// components/basedev/file_access/trusted_folders.h
class TrustedFolderManager {
 public:
  // User grants access to folder
  void GrantAccess(const base::FilePath& folder_path);

  // Check if folder is trusted
  bool IsTrusted(const base::FilePath& folder_path);

  // Persist to user profile
  void SaveToProfile();
  void LoadFromProfile();

 private:
  std::vector<base::FilePath> trusted_folders_;
};
```

### Terminal Backend

**Process Spawning**:
```cpp
// components/basedev/terminal/terminal_backend.h
class TerminalBackend {
 public:
  // Spawn shell process
  void SpawnShell(const std::string& shell_path);

  // Send input to shell
  void SendInput(const std::string& input);

  // Stream output
  void OnOutputReceived(base::RepeatingCallback<void(const std::string&)> callback);

 private:
  base::Process shell_process_;
  // PTY (pseudo-terminal) handling
};
```

## Dependencies

**External Libraries**:
- Monaco Editor (Microsoft, MIT license)
- Terminal emulation library (xterm.js or similar)

**Chromium APIs**:
- File System Access API
- WebUI framework
- Mojo IPC
- Process spawning APIs

**Build Tools**:
- GN/Ninja build system
- TypeScript compiler (for frontend)
- Node.js (for Monaco bundling)

## Integration Points

- **Browser Tabs**: Custom tab type registration
- **Sidepanels**: File explorer, AI assistant
- **WebUI**: Monaco editor, terminal UI
- **Profile System**: Trusted folders, settings
- **AI Assistant**: Code context sharing

## Testing

### Test Plan

**Unit Tests**:
- [ ] Tab type creation/destruction
- [ ] File operations (read/write/delete)
- [ ] Terminal input/output handling
- [ ] Permission management
- [ ] Monaco editor operations

**Integration Tests**:
- [ ] Open code editor tab
- [ ] Grant folder access
- [ ] Load file into editor
- [ ] Edit and save file
- [ ] Run terminal commands
- [ ] AI assistant interaction

**Performance Tests**:
- [ ] Large file handling (>10MB)
- [ ] Large directory trees (>10k files)
- [ ] Terminal output streaming
- [ ] Multiple open files
- [ ] Memory usage

**Security Tests**:
- [ ] Unauthorized file access attempts
- [ ] Terminal escape/injection attacks
- [ ] Permission persistence
- [ ] Sandbox isolation

### Test Checklist

**Basic Functionality**:
- [ ] Can open chrome://code/ tab
- [ ] No address bar visible
- [ ] Can select trusted folder
- [ ] File explorer shows directory tree
- [ ] Can open file in Monaco editor
- [ ] Syntax highlighting works
- [ ] Can edit and save file
- [ ] Terminal opens and accepts commands
- [ ] AI assistant responds to code questions

**Edge Cases**:
- [ ] Binary file handling
- [ ] Permission denied scenarios
- [ ] Very large files
- [ ] Special characters in filenames
- [ ] Network drives/remote folders
- [ ] Symlinks
- [ ] Terminal crashes
- [ ] Monaco editor crashes

## Documentation

### User Documentation
- Location: `docs/CODE_EDITOR.md` (to be created)
- Content:
  - How to open code editor
  - Granting folder access
  - Using the editor
  - Terminal usage
  - AI assistant features
  - Keyboard shortcuts

### Developer Documentation
- Location: `guides/CODE_EDITOR_DEV.md` (to be created)
- Content:
  - Architecture overview
  - Custom tab type implementation
  - Monaco integration
  - File system API usage
  - Terminal backend
  - Testing guide

## Related

### References
- [VS Code Architecture](https://github.com/microsoft/vscode/wiki/Source-Code-Organization)
- [Monaco Editor Docs](https://microsoft.github.io/monaco-editor/)
- [File System Access API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API)
- [Chromium WebUI](https://chromium.googlesource.com/chromium/src/+/main/docs/webui_explainer.md)
- [Chromium Tab System](https://chromium.googlesource.com/chromium/src/+/main/docs/ui/views/overview.md)

### Related Features
- Base Browser (ready)
- AI Assistant (sidepanel)
- Login with Base (future)
- Complete Branding System (in progress)

## Outcomes

### Success Criteria
- Can open chrome://code/ and see Monaco editor
- Can select folder and see files in explorer
- Can edit and save files with full code intelligence
- Terminal works like VS Code's terminal
- AI assistant understands code context
- Performance matches or exceeds VS Code for basic operations
- Zero file system security vulnerabilities
- Seamless integration with browser workflow

### Metrics
- Tab open time: <1 second
- File load time: <500ms for <1MB files
- Terminal response time: <100ms
- Memory usage: Similar to VS Code
- File operations: Match native file system speed

## Next Steps

### Immediate Actions
1. **Research Phase**:
   - [ ] Study Chromium's tab type system
   - [ ] Review Monaco Editor integration examples
   - [ ] Research File System Access API implementation
   - [ ] Study terminal emulation options

2. **Prototype**:
   - [ ] Create minimal custom tab type
   - [ ] Integrate Monaco in WebUI page
   - [ ] Test basic file operations
   - [ ] Prove terminal integration feasibility

3. **Implementation**:
   - [ ] Follow implementation plan phases
   - [ ] Regular testing and iteration
   - [ ] Documentation as we go

### Long-term
- [ ] Move to `progress/past/` when complete
- [ ] Create generator tool for code editor extensions
- [ ] Add plugin system for language support
- [ ] Consider collaborative editing features

## Notes

### Design Principles

1. **Leverage Proven Technology**: Use Monaco Editor and VS Code patterns rather than building from scratch
2. **Security First**: Trusted folders and clear user permissions
3. **Seamless Integration**: Code editor feels native to Base Browser
4. **Performance**: Match or exceed VS Code for common operations
5. **Developer-Friendly**: Follow Chromium conventions and basedev_ naming

### VS Code Patterns to Adopt

- Trusted folders for workspace security
- Command palette for quick actions
- Settings sync across sessions
- Extension marketplace (future consideration)
- Git integration in sidebar
- Integrated terminal positioning and behavior

### Custom Sidepanels for Code Editor Tab

Unlike browser tabs, the code editor tab will have dedicated sidepanels:
- **Left**: File Explorer (always attached to code tab)
- **Right**: AI Assistant (code-context aware)
- **Bottom**: Terminal (part of center panel split)

These sidepanels only appear when code editor tab is active.

### Philosophy

"We don't want to reinvent much here, VS Code has already done it."

This guides all implementation decisions:
- Use Monaco Editor (VS Code's editor)
- Follow VS Code's UX patterns
- Adopt VS Code's security model
- Match VS Code's performance characteristics
- Leverage existing open-source components

The goal is to bring VS Code-quality editing experience into the browser, not to compete with VS Code from scratch.

## Questions to Resolve

- [ ] Which terminal emulation library? (xterm.js likely candidate)
- [ ] How to bundle Monaco Editor in Chromium build?
- [ ] Should git integration be in v1 or future?
- [ ] Settings sync with Login with Base?
- [ ] Extension system architecture?
- [ ] Multi-window code editor support?
- [ ] Collaboration features priority?

## Resources Needed

- Monaco Editor source/bundle
- Terminal emulation library
- File icons asset pack
- TypeScript expertise for frontend
- Chromium WebUI expertise
- Security review resources
