# Feature: AI Assistant with MCP Integration

## Metadata

- **Status**: Planning
- **Started**: 2025-11-09
- **Completed**: TBD
- **Category**: Core Feature | AI Assistant
- **Priority**: Critical
- **Contributors**: Development Team

## Overview

Integrate a tiered AI Assistant as a sidepanel that is context-aware and framework-intelligent. The system uses a fast, on-device local model (BaseIntelligence - fine-tuned Gemma 3N) for most tasks, with intelligent escalation to cloud models (Sonnet 4.5) for complex queries. The assistant automatically detects the user's development framework and configures appropriate LSP servers, MCP servers, and development tools to provide the best developer experience (DX).

**BaseIntelligence**: Fine-tuned Gemma 3N optimized for Base Browser workflows, runs entirely on-device with vision capabilities.

## Goals

- [ ] Create AI Assistant sidepanel (works in both browser and code editor)
- [ ] Implement framework detection system
- [ ] Integrate MCP (Model Context Protocol) server support
- [ ] Auto-configure LSP servers based on detected framework
- [ ] Support browsermcp.io for web UI development
- [ ] Context-aware assistance (browser mode vs code editor mode)
- [ ] Centralized framework registry (updateable from base.al servers)
- [ ] Seamless tool installation and configuration

## Vision

The AI Assistant is the third pillar of Base Browser's 3-in-1 architecture:
1. Browser (ready)
2. Code Editor (planned)
3. **AI Assistant** (this feature)

Unlike generic AI assistants, Base Browser's AI is **framework-aware**:
- Automatically detects what framework the user is working with
- Configures the right tools (LSP, MCP, linters, formatters) automatically
- Provides framework-specific guidance and best practices
- Understands project structure and conventions
- Integrates with development workflow seamlessly

**Philosophy**: "Best DX (Developer Experience) by being smart about context"

## Technical Approach

### Architecture

**Tiered AI System**:

```
User Query
    ↓
BaseIntelligence (Local - Gemma 3N)
├── Always running on-device
├── Instant responses (<100ms)
├── Vision capable (screenshots, UI analysis)
├── Tool calling (MCP servers)
├── Framework-aware
├── Privacy-preserving (data never leaves device)
│
├─→ [~90% queries] Handle locally
│   ├── Simple queries
│   ├── Code suggestions
│   ├── Framework help
│   ├── UI debugging
│   ├── File operations
│   └── Terminal commands
│
└─→ [~10% queries] Escalate to cloud
    ↓
    "Calling special forces: Sonnet 4.5 🚀"
    ↓
    BaseIntelligence prepares handoff:
    ├── Problem summary
    ├── Full context from Context Service
    ├── Attempted solutions
    ├── User's full history
    └── Specific question for cloud AI
        ↓
    Cloud AI (Sonnet 4.5 / Opus)
    ├── Deep reasoning
    ├── Complex refactoring
    ├── Architecture design
    ├── Advanced debugging
    └── Returns detailed solution
        ↓
    BaseIntelligence:
    ├── Receives cloud response
    ├── Summarizes for user
    ├── Executes solution
    └── Learns from interaction
```

**BaseIntelligence Fine-tuning**:
- Base model: Gemma 3N (nano - 2B params)
- Training data: Base Browser workflows, common dev tasks
- Optimization: Browser-specific prompts, MCP tool usage
- Vision: Screenshot analysis, UI debugging
- Size: ~1.5GB on disk, ~2GB in memory
- Speed: 30-50 tokens/sec on M1/M2

**Context-Aware Design**:
- **Browser Mode**: General AI assistance, research, content analysis
- **Code Editor Mode**: Framework-aware development assistance
- **Dual Context**: Same AI instance with different tool access based on mode

**Framework Detection System**:
1. User opens project folder in Code Editor
2. Browser scans for framework indicators (package.json, go.mod, etc.)
3. Matches against framework registry (fetched from base.al)
4. Auto-installs/configures appropriate tools
5. AI Assistant gains framework-specific context

**MCP Server Integration**:
- Multiple MCP servers running concurrently
- Framework-specific MCP servers loaded on demand
- Standard MCP servers always available (filesystem, git)
- BrowserMCP for web framework UI development

### Components

**AI Assistant Sidepanel**:
- WebUI-based chat interface
- Context indicator (shows current mode and detected framework)
- Tool status display (LSP, MCP servers running)
- Settings for manual framework override

**Framework Registry**:
- JSON file hosted on base.al servers
- Fetched on startup / periodically updated
- Cached locally for offline use
- Contains detection rules and tool configurations

**Framework Detector**:
- Scans project files for framework indicators
- Matches against registry patterns
- Supports multiple simultaneous frameworks (e.g., Next.js + Go backend)
- Confidence scoring for ambiguous cases

**MCP Server Manager**:
- Spawns/manages MCP server processes
- Routes MCP requests to appropriate servers
- Handles server lifecycle (start, stop, restart)
- Monitors server health

**LSP Integration**:
- Manages language server processes
- Provides code intelligence to Monaco Editor
- Framework-aware LSP configuration
- Multiple LSP servers for polyglot projects

**Tool Installer**:
- Downloads and installs LSP servers
- Downloads and installs MCP servers
- Version management
- Dependency resolution

### Files to Create/Modify

```
chrome/browser/ui/views/side_panel/basedev/
├── ai_assistant_panel.h/cc                # AI sidepanel
├── ai_assistant_coordinator.h/cc          # Coordinator
└── BUILD.gn

chrome/browser/ui/webui/basedev/ai_assistant/
├── ai_assistant_ui.h/cc                   # WebUI handler
├── ai_assistant_page_handler.h/cc         # Backend logic
├── resources/
│   ├── index.html                         # Chat interface
│   ├── chat.ts                            # Chat component
│   ├── framework_indicator.ts             # Shows detected framework
│   ├── tool_status.ts                     # LSP/MCP status
│   └── styles.css
└── BUILD.gn

components/basedev/
├── framework_detection/
│   ├── framework_detector.h/cc            # Core detection logic
│   ├── framework_registry.h/cc            # Registry management
│   ├── framework_registry_fetcher.h/cc    # Fetch from base.al
│   └── BUILD.gn
├── mcp/
│   ├── mcp_server_manager.h/cc            # MCP server lifecycle
│   ├── mcp_client.h/cc                    # MCP client implementation
│   ├── mcp_router.h/cc                    # Route requests to servers
│   └── BUILD.gn
├── lsp/
│   ├── lsp_manager.h/cc                   # LSP lifecycle
│   ├── lsp_client.h/cc                    # LSP client
│   └── BUILD.gn
├── tool_installer/
│   ├── tool_installer.h/cc                # Download/install tools
│   ├── tool_registry.h/cc                 # Known tools
│   └── BUILD.gn
└── BUILD.gn
```

## Implementation Plan

### Phase 1: AI Assistant Sidepanel Foundation
- [ ] Create basic AI sidepanel UI
- [ ] Implement chat interface (WebUI)
- [ ] Connect to AI backend (initially generic)
- [ ] Test in browser mode
- [ ] Test in code editor mode
- [ ] Add context switching logic

### Phase 2: Framework Detection System
- [ ] Design framework registry JSON schema
- [ ] Create framework detector implementation
- [ ] Implement file scanning (package.json, go.mod, etc.)
- [ ] Pattern matching engine
- [ ] Support common frameworks (Next, Nuxt, Go, Flutter, Base)
- [ ] Test detection accuracy
- [ ] Add confidence scoring

### Phase 3: Framework Registry Infrastructure
- [ ] Design registry hosting on base.al
- [ ] Implement registry fetcher
- [ ] Add caching mechanism
- [ ] Periodic update checks
- [ ] Fallback to local cache when offline
- [ ] Registry versioning

### Phase 4: MCP Server Integration
- [ ] Research MCP protocol implementation
- [ ] Create MCP server manager
- [ ] Implement MCP client
- [ ] Add process spawning and lifecycle
- [ ] Integrate browsermcp.io
- [ ] Add filesystem MCP
- [ ] Add git MCP
- [ ] Test MCP routing

### Phase 5: LSP Integration
- [ ] Create LSP manager
- [ ] Implement LSP client (Language Server Protocol)
- [ ] Connect to Monaco Editor
- [ ] Support TypeScript LSP
- [ ] Support Go LSP (gopls)
- [ ] Support Dart LSP (for Flutter)
- [ ] Test code intelligence features

### Phase 6: Tool Auto-Installation
- [ ] Design tool installer architecture
- [ ] Implement download mechanism
- [ ] Add tool verification (checksums)
- [ ] Version management
- [ ] Dependency resolution
- [ ] Progress indicators
- [ ] Error handling and retry logic

### Phase 7: Framework-Specific Features
- [ ] Nuxt-specific assistance
- [ ] Next.js-specific assistance
- [ ] Go framework assistance
- [ ] Flutter assistance
- [ ] Base framework assistance
- [ ] Framework documentation integration
- [ ] Framework best practices

### Phase 8: Polish & Advanced Features
- [ ] Manual framework override
- [ ] Multi-framework projects
- [ ] Custom framework definitions (user-provided)
- [ ] Tool settings and preferences
- [ ] Performance optimization
- [ ] Offline mode improvements
- [ ] Analytics (framework usage, tool popularity)

## Progress Log

### 2025-11-09 - Planning & Vision
- Discussed AI Assistant vision and framework-awareness
- Decided on centralized, updateable framework registry
- Planned MCP server integration (browsermcp.io for web dev)
- Established "best DX" philosophy
- Created feature plan document

## Challenges & Solutions

### Challenge 1: Framework Detection Accuracy
**Problem**: Need to accurately detect frameworks without false positives

**Proposed Solution**:
- Multiple detection methods (file existence, dependency patterns, content analysis)
- Confidence scoring to handle ambiguous cases
- User override option
- Learn from user corrections over time

**Status**: Planning

### Challenge 2: Tool Installation Security
**Problem**: Installing LSP/MCP servers requires downloading executables

**Proposed Solution**:
- Verified tool registry (curated by Base team)
- Checksum verification
- Sandboxed execution where possible
- User consent for installations
- Tool signatures/code signing

**Status**: Planning

### Challenge 3: MCP Server Process Management
**Problem**: Managing multiple background processes (LSP, MCP servers)

**Proposed Solution**:
- Process pool management
- Resource limits (CPU, memory)
- Automatic restart on crashes
- Clean shutdown on browser close
- Health monitoring and alerting

**Status**: Planning

### Challenge 4: Framework Registry Updates
**Problem**: Need to update framework definitions without browser updates

**Proposed Solution**:
- Host registry on base.al (centralized, updateable)
- Periodic fetch with local caching
- Version-aware updates
- Rollback mechanism for bad updates
- Community contributions possible

**Status**: Planning

## Technical Details

### Framework Registry Schema (Draft)

```json
{
  "version": "1.0.0",
  "last_updated": "2025-11-09T00:00:00Z",
  "frameworks": [
    {
      "id": "nuxt",
      "name": "Nuxt",
      "versions": ["3.x", "4.x"],
      "detectors": [
        {
          "type": "package_json_dependency",
          "pattern": "^nuxt",
          "confidence": 0.9
        },
        {
          "type": "file_exists",
          "path": "nuxt.config.ts",
          "confidence": 0.8
        },
        {
          "type": "directory_structure",
          "paths": ["pages/", "components/"],
          "confidence": 0.6
        }
      ],
      "tools": {
        "lsp": [
          {
            "name": "typescript-language-server",
            "version": "latest",
            "download_url": "...",
            "checksum": "..."
          },
          {
            "name": "vue-language-server",
            "version": "latest",
            "download_url": "...",
            "checksum": "..."
          }
        ],
        "mcp": ["browsermcp", "filesystem"],
        "formatter": ["prettier"],
        "linter": ["eslint"]
      },
      "context": {
        "docs_url": "https://nuxt.com/docs",
        "structure": {
          "pages/": "Page components with file-based routing",
          "components/": "Vue components auto-imported",
          "composables/": "Auto-imported composables",
          "server/": "Server API routes and middleware"
        },
        "common_patterns": [
          "Use composables for state management",
          "Server routes in server/api/",
          "Middleware in middleware/"
        ]
      }
    },
    {
      "id": "base",
      "name": "Base Framework",
      "versions": ["1.x"],
      "detectors": [
        {
          "type": "file_exists",
          "path": "base.config.go",
          "confidence": 0.95
        },
        {
          "type": "go_mod_dependency",
          "pattern": "github.com/base-org/base",
          "confidence": 0.9
        }
      ],
      "tools": {
        "lsp": [
          {
            "name": "gopls",
            "version": "latest",
            "download_url": "...",
            "checksum": "..."
          }
        ],
        "mcp": ["base-mcp", "filesystem", "git"],
        "formatter": ["gofmt"],
        "linter": ["golangci-lint"]
      },
      "context": {
        "docs_url": "https://docs.base.al",
        "structure": {
          "modules/": "Base framework modules",
          "core/": "Core application logic",
          "services/": "Business services"
        }
      }
    },
    {
      "id": "flutter",
      "name": "Flutter",
      "detectors": [
        {
          "type": "file_exists",
          "path": "pubspec.yaml",
          "confidence": 0.95
        },
        {
          "type": "pubspec_dependency",
          "pattern": "flutter:",
          "confidence": 0.9
        }
      ],
      "tools": {
        "lsp": [
          {
            "name": "dart-language-server",
            "version": "latest",
            "download_url": "...",
            "checksum": "..."
          }
        ],
        "mcp": ["filesystem"],
        "formatter": ["dart format"],
        "linter": ["dart analyze"]
      },
      "context": {
        "docs_url": "https://docs.flutter.dev",
        "structure": {
          "lib/": "Dart source code",
          "test/": "Unit tests",
          "android/": "Android platform code",
          "ios/": "iOS platform code"
        }
      }
    }
  ]
}
```

### MCP Server Architecture

**Server Process Model**:
- Each MCP server runs as separate process
- Communication via stdio or HTTP
- Browser manages process lifecycle
- Graceful shutdown on browser close

**Supported MCP Servers** (Initial):
1. **browsermcp.io**: Web UI automation and testing
2. **filesystem**: File operations
3. **git**: Git operations
4. **base-mcp**: Base framework specific tools
5. **database**: Database access (postgres, sqlite, etc.)

### BrowserMCP Integration

**Use Case**: AI assists with web development
- "Create a responsive navbar"
  - AI generates code
  - Uses browsermcp to preview in browser
  - Tests responsive behavior
  - Suggests improvements

**Capabilities**:
- DOM manipulation
- Element inspection
- Screenshot capture
- Click/type/navigate
- Visual regression testing

### Context-Aware Behavior

**Browser Mode**:
- General web assistance
- Research and information lookup
- Content summarization
- Page analysis
- No framework-specific tools loaded

**Code Editor Mode**:
- Framework detection active
- LSP servers running
- MCP servers loaded (framework-specific)
- Code intelligence
- Framework best practices
- Project structure awareness

**Switching**: Automatic when user switches tabs

## Dependencies

**External Tools** (auto-installed):
- Language servers (gopls, typescript-language-server, etc.)
- MCP servers (browsermcp, etc.)
- Formatters (prettier, gofmt, etc.)
- Linters (eslint, golangci-lint, etc.)

**External Services**:
- base.al servers (framework registry, tool downloads)
- AI backend API
- MCP server registry

**Browser APIs**:
- Process spawning (for LSP/MCP servers)
- Network (for downloads and updates)
- File system (for tool installation)
- WebUI framework

## Integration Points

- **Code Editor**: LSP integration with Monaco Editor
- **Browser Tabs**: Context awareness
- **File System**: Framework detection via file scanning
- **Terminal**: Can suggest and run commands
- **Sidepanel System**: AI Assistant as sidepanel

## Testing

### Test Plan

**Framework Detection**:
- [ ] Test with Nuxt projects
- [ ] Test with Next.js projects
- [ ] Test with Go projects
- [ ] Test with Flutter projects
- [ ] Test with Base framework projects
- [ ] Test with multi-framework projects (monorepos)
- [ ] Test detection accuracy and confidence scores
- [ ] Test with ambiguous projects

**MCP Integration**:
- [ ] Test MCP server spawning
- [ ] Test MCP communication protocol
- [ ] Test browsermcp.io operations
- [ ] Test filesystem MCP
- [ ] Test git MCP
- [ ] Test concurrent MCP servers
- [ ] Test MCP server crashes and recovery

**LSP Integration**:
- [ ] Test TypeScript LSP
- [ ] Test Go LSP
- [ ] Test Dart LSP
- [ ] Test code completion
- [ ] Test go-to-definition
- [ ] Test error reporting
- [ ] Test multiple LSP servers

**Tool Installation**:
- [ ] Test tool downloads
- [ ] Test checksum verification
- [ ] Test version management
- [ ] Test offline behavior
- [ ] Test installation failures
- [ ] Test disk space limits

**Context Switching**:
- [ ] Test browser to code editor switch
- [ ] Test code editor to browser switch
- [ ] Test context state preservation
- [ ] Test tool lifecycle during switches

### Test Results
- Status: Not started
- Coverage: 0%
- Issues found: None yet

## Documentation

### User Documentation
- Location: `docs/AI_ASSISTANT.md` (to be created)
- Content:
  - Using the AI Assistant
  - Framework detection
  - Installing tools
  - MCP server usage
  - Troubleshooting

### Developer Documentation
- Location: `guides/AI_ASSISTANT_DEV.md` (to be created)
- Content:
  - Architecture overview
  - Framework registry format
  - Adding new framework definitions
  - MCP server integration
  - LSP integration
  - Tool installer implementation

### Framework Registry Documentation
- Location: `docs/FRAMEWORK_REGISTRY.md` (to be created)
- Content:
  - Registry schema specification
  - Detection pattern syntax
  - Contributing new frameworks
  - Testing framework definitions
  - Best practices

## Related

### References
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [BrowserMCP](https://browsermcp.io/)
- [Language Server Protocol](https://microsoft.github.io/language-server-protocol/)
- [VS Code Extension API](https://code.visualstudio.com/api)

### Related Features
- Browser (ready)
- Code Editor (planned)
- Login with Base (future - for syncing preferences)
- Complete Branding System (in progress)

## Outcomes

### Success Criteria
- AI Assistant automatically detects 95%+ of common frameworks
- LSP servers provide full code intelligence
- MCP servers enable AI to perform actual development tasks
- Tool installation is seamless and secure
- Framework registry stays up-to-date
- Best-in-class developer experience
- Offline capability after initial setup

### Metrics
- Framework detection accuracy: >95%
- Tool installation success rate: >99%
- Average tool installation time: <30 seconds
- MCP server uptime: >99%
- LSP response time: <100ms
- User satisfaction: Framework-specific assistance useful

## Next Steps

### Immediate Actions
1. **Research Phase**:
   - [ ] Study MCP protocol in detail
   - [ ] Review browsermcp.io capabilities
   - [ ] Research LSP client implementation
   - [ ] Study framework detection patterns

2. **Prototype**:
   - [ ] Create basic AI sidepanel
   - [ ] Implement simple framework detector (Nuxt, Go)
   - [ ] Test MCP server spawning
   - [ ] Prove LSP integration feasibility

3. **Infrastructure**:
   - [ ] Design framework registry schema (detailed)
   - [ ] Set up registry hosting on base.al
   - [ ] Create initial framework definitions
   - [ ] Build registry update mechanism

### Long-term
- [ ] Move to `progress/past/` when complete
- [ ] Create framework definition contribution system
- [ ] Add more MCP servers
- [ ] Community-contributed framework definitions
- [ ] AI model fine-tuning on framework-specific data

## Notes

### Design Principles

1. **Framework-Aware**: Automatically understand what the user is building
2. **Zero Configuration**: Tools just work without manual setup
3. **Always Updated**: Framework definitions update without browser updates
4. **Offline-Capable**: Work continues after initial tool installation
5. **Secure by Default**: Verified tools, sandboxed execution
6. **Best DX**: Make developers productive immediately

### Framework Registry Benefits

**Updateability**:
- New frameworks added without browser updates
- Framework definitions improved continuously
- Bug fixes deployed instantly
- Community contributions possible

**Flexibility**:
- Framework maintainers can update their own definitions
- Version-specific configurations
- Custom tool chains
- Platform-specific tools

**Discoverability**:
- Users see supported frameworks
- Framework usage analytics
- Popular tool combinations
- Community best practices

### MCP vs Extension API

**Why MCP over browser extensions?**
- Standardized protocol
- Language-agnostic servers
- Reusable across tools (not just browsers)
- Active development and community
- Better security model
- Easier to distribute and update

### BrowserMCP Specific Use Cases

**Web Development Workflow**:
1. User: "Create a responsive header"
2. AI generates HTML/CSS
3. BrowserMCP opens preview
4. AI tests responsive breakpoints
5. AI suggests improvements
6. User approves, code saved

**Visual Debugging**:
1. User: "Why is this layout broken?"
2. AI inspects DOM via BrowserMCP
3. AI identifies CSS issue
4. AI suggests fix
5. BrowserMCP previews fix
6. User approves

### Context Switching Logic

**Browser Tab Active**:
- Framework detection: OFF
- LSP servers: OFF (or paused)
- MCP servers: Basic (filesystem, git)
- AI context: Browser mode

**Code Editor Tab Active**:
- Framework detection: ON
- LSP servers: ON (framework-specific)
- MCP servers: All (including browsermcp for web frameworks)
- AI context: Code editor mode + framework context

**Resource Management**:
- Pause/resume servers on context switch
- Keep LSP servers warm (don't kill)
- Kill MCP servers after inactivity period
- Restart automatically when needed

## Questions to Resolve

- [ ] Which AI model/backend to use?
- [ ] Self-hosted AI or API-based?
- [ ] MCP server sandboxing approach?
- [ ] Tool installation location (user data directory?)
- [ ] Maximum number of concurrent MCP servers?
- [ ] Framework registry update frequency?
- [ ] Offline AI capabilities?
- [ ] Framework detection confidence threshold?
- [ ] User override UI design?
- [ ] Tool version update policy?

## Resources Needed

- AI backend infrastructure (or API credits)
- base.al server space for framework registry
- Tool download hosting (or CDN)
- MCP server implementations
- LSP server binaries
- Testing infrastructure
- Framework definition expertise
