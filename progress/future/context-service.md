# Feature: Context Service

## Metadata

- **Status**: Planning
- **Started**: 2025-11-09
- **Completed**: TBD
- **Category**: Core Component | Infrastructure
- **Priority**: Critical (prerequisite for AI Assistant)
- **Contributors**: Development Team

## Overview

Create a centralized Context Service that aggregates all relevant information about the user's current state, environment, and activities. This service provides rich context to the AI Assistant, enabling it to give accurate, contextual assistance for both browsing and development workflows.

## Goals

- [ ] Aggregate visual context (screenshots, DOM, layout)
- [ ] Capture code context (open files, cursor position, git state)
- [ ] Monitor runtime context (console logs, network, errors)
- [ ] Track user context (workflow, recent actions, tab state)
- [ ] Provide system context (environment, tools, resources)
- [ ] Efficient context serialization for AI consumption
- [ ] Privacy controls (what context to share)
- [ ] Real-time context updates
- [ ] Context history and replay

## Vision

The Context Service is the "eyes and ears" of the AI Assistant. It continuously monitors everything happening in the browser and code editor, building a comprehensive understanding of the user's current state. This allows the AI to provide assistance that feels intelligent and aware, rather than generic.

**Philosophy**: "The AI can't help if it can't see what you see"

## Technical Approach

### Architecture

**Separate Helper Process Model** (like Chromium Helper.app):
- Dedicated `Base Context.app` helper process
- Runs in background alongside browser
- Isolated from main browser process (stability + security)
- Communicates via Mojo IPC
- Can be restarted independently if it crashes
- Dedicated resources (CPU, memory) for context collection
- Follows macOS helper app conventions

**Process Architecture**:
```
Base Dev.app (Main Browser)
├── Browser Process
│   └── Context Service Client (IPC)
│       └── Mojo Connection to Base Context.app
├── Renderer Processes (tabs)
│   └── Context Collectors (DOM, console, etc.)
│       └── Send to Base Context.app
└── GPU Process

Base Context.app (Helper Process)
├── Context Aggregator
├── Context Collectors
│   ├── Visual Context Collector
│   ├── Code Context Collector
│   ├── Runtime Context Collector
│   ├── User Context Collector
│   └── System Context Collector
├── Context Storage (history)
├── Privacy Filter
└── Mojo IPC Server
```

**Benefits of Separate Process**:
- Isolation: Context collection won't crash browser
- Performance: Dedicated resources, no interference
- Security: Sandboxed helper with limited permissions
- Modularity: Can update Context Service independently
- Resource Management: Can be throttled or paused independently

**Context Categories**:

1. **Visual Context**
   - Current tab screenshot (on-demand)
   - DOM snapshot (structure + computed styles)
   - Layout tree (boxes, positions, overflow)
   - Viewport information
   - UI state (modals, sidepanels, overlays)

2. **Code Context** (Code Editor mode)
   - Open files with full content
   - Cursor positions and selections
   - File tree structure
   - Recently edited files
   - Git status (branch, changes, commits)
   - Framework detection results
   - LSP diagnostics (errors, warnings)

3. **Runtime Context**
   - JavaScript console logs (all levels)
   - Network requests (URLs, status, timing, headers)
   - Errors and warnings (JS errors, CSP violations)
   - Performance metrics (FCP, LCP, CLS, etc.)
   - Terminal output (last N lines)
   - Process information

4. **User Context**
   - Current mode (browser vs code editor)
   - Active tab and window information
   - All open tabs (URLs, titles)
   - Recent user actions (clicks, navigation, typing)
   - Search queries
   - Current workflow (detected pattern)
   - Session duration

5. **System Context**
   - OS and architecture
   - Browser version
   - Installed tools (LSP servers, MCP servers)
   - Resource usage (CPU, memory)
   - Disk space
   - Network status (online/offline)

### Components

**Core Service**:
```
components/basedev/context_service/
├── context_service.h/cc              # Main service
├── context_aggregator.h/cc           # Aggregates from sources
├── context_serializer.h/cc           # Serialize to JSON/protobuf
├── context_types.h                   # Type definitions
└── BUILD.gn
```

**Context Collectors** (specialized collectors for each category):
```
components/basedev/context_service/collectors/
├── visual_context_collector.h/cc     # Screenshots, DOM
├── code_context_collector.h/cc       # Files, git, LSP
├── runtime_context_collector.h/cc    # Console, network, errors
├── user_context_collector.h/cc       # Actions, tabs, workflow
├── system_context_collector.h/cc     # OS, tools, resources
└── BUILD.gn
```

**Context Storage** (for history and replay):
```
components/basedev/context_service/storage/
├── context_history.h/cc              # Store context snapshots
├── context_replay.h/cc               # Replay past context
└── BUILD.gn
```

**Privacy Controls**:
```
components/basedev/context_service/privacy/
├── context_filter.h/cc               # Filter sensitive data
├── privacy_settings.h/cc             # User privacy preferences
└── BUILD.gn
```

### Files to Create/Modify

```
# Helper App Executable
chrome/app/base_context_main.cc           # Main entry point for Base Context.app
chrome/app/base_context.entitlements      # macOS entitlements

# Helper App Structure (built as Base Context.app)
Base Dev.app/
└── Contents/
    └── Frameworks/
        └── Base Dev Framework.framework/
            └── Helpers/
                └── Base Context.app/           # The helper process
                    ├── Contents/
                    │   ├── MacOS/
                    │   │   └── Base Context    # Executable
                    │   ├── Info.plist
                    │   └── Resources/
                    └── ...

# Context Service Components (runs in Base Context.app)
components/basedev/context_service/
├── context_service.h/cc              # Main context service (in helper)
├── context_aggregator.h/cc           # Aggregate all context
├── context_serializer.h/cc           # Serialize for AI
├── context_types.h                   # Data structures
├── context_api.h/cc                  # Public API for consumers
├── collectors/
│   ├── visual_context_collector.h/cc
│   ├── code_context_collector.h/cc
│   ├── runtime_context_collector.h/cc
│   ├── user_context_collector.h/cc
│   ├── system_context_collector.h/cc
│   └── BUILD.gn
├── storage/
│   ├── context_history.h/cc
│   ├── context_replay.h/cc
│   └── BUILD.gn
├── privacy/
│   ├── context_filter.h/cc
│   ├── privacy_settings.h/cc
│   └── BUILD.gn
└── BUILD.gn

# Context Service Client (runs in main browser)
chrome/browser/basedev/context_service/
├── context_service_client.h/cc       # Client that connects to helper
├── context_service_launcher.h/cc     # Launches helper process
└── BUILD.gn

# Mojo Interface (IPC between browser and helper)
chrome/browser/basedev/context_service/mojo/
├── context_service.mojom             # Mojo interface definition
└── BUILD.gn
```

## Implementation Plan

### Phase 1: Core Infrastructure
- [ ] Design context data structures
- [ ] Create context service skeleton
- [ ] Implement context aggregator
- [ ] Create basic serialization (JSON)
- [ ] Test service lifecycle

### Phase 2: Visual Context Collection
- [ ] Implement screenshot capture
- [ ] DOM snapshot extraction
- [ ] Layout tree capture
- [ ] Viewport information
- [ ] UI state tracking
- [ ] Test visual context accuracy

### Phase 3: Code Context Collection
- [ ] Open files tracking
- [ ] Cursor and selection tracking
- [ ] File tree structure
- [ ] Git integration
- [ ] LSP diagnostics integration
- [ ] Test code context completeness

### Phase 4: Runtime Context Collection
- [ ] Console log interception
- [ ] Network request monitoring
- [ ] Error and warning collection
- [ ] Performance metrics
- [ ] Terminal output capture
- [ ] Test runtime context accuracy

### Phase 5: User Context Collection
- [ ] Tab and window tracking
- [ ] User action logging
- [ ] Workflow detection
- [ ] Session management
- [ ] Test user context patterns

### Phase 6: System Context Collection
- [ ] OS and environment detection
- [ ] Tool discovery
- [ ] Resource monitoring
- [ ] Network status
- [ ] Test system context reliability

### Phase 7: Privacy & Filtering
- [ ] Implement context filters
- [ ] Privacy settings UI
- [ ] Sensitive data detection
- [ ] User consent management
- [ ] Test privacy controls

### Phase 8: History & Optimization
- [ ] Context history storage
- [ ] Context replay functionality
- [ ] Optimize serialization
- [ ] Reduce memory footprint
- [ ] Performance testing

## Progress Log

### 2025-11-09 - Planning
- Identified need for centralized context service
- Defined context categories (visual, code, runtime, user, system)
- Planned architecture and components
- Created feature plan

## Challenges & Solutions

### Challenge 1: Performance Impact
**Problem**: Collecting comprehensive context could impact browser performance

**Proposed Solution**:
- Lazy collection (only when AI Assistant is active)
- Sampling (not every frame/event)
- Incremental updates (deltas, not full snapshots)
- Background processing
- Smart throttling

**Status**: Planning

### Challenge 2: Privacy Concerns
**Problem**: Context may contain sensitive user data (passwords, personal info)

**Proposed Solution**:
- User controls (what to collect)
- Automatic sensitive data detection (password fields, credit cards)
- Local-only storage
- Clear privacy policy
- Opt-in for sensitive categories

**Status**: Planning

### Challenge 3: Context Size
**Problem**: Full context can be very large (DOM, screenshots, logs)

**Proposed Solution**:
- Smart summarization
- Compress before serialization
- Stream large items (screenshots)
- Prune old context
- Configurable retention

**Status**: Planning

### Challenge 4: Cross-Process Context
**Problem**: Browser uses multi-process architecture, context scattered across processes

**Proposed Solution**:
- Mojo IPC for cross-process communication
- Centralize in browser process
- Collector agents in renderer processes
- Efficient IPC serialization

**Status**: Planning

## Technical Details

### Context Data Structure

```cpp
// components/basedev/context_service/context_types.h

struct VisualContext {
  // Screenshot (optional, can be large)
  std::optional<SkBitmap> screenshot;

  // DOM snapshot (simplified)
  std::string dom_snapshot;

  // Layout information
  gfx::Rect viewport;
  std::vector<LayoutBox> layout_tree;

  // UI state
  bool has_modal;
  std::vector<std::string> active_sidepanels;
};

struct CodeContext {
  // Open files
  std::vector<OpenFile> open_files;

  // Current file and cursor
  std::string current_file_path;
  int cursor_line;
  int cursor_column;

  // File tree
  FileTreeNode file_tree_root;

  // Git status
  GitStatus git_status;

  // LSP diagnostics
  std::vector<Diagnostic> diagnostics;

  // Framework info
  std::string detected_framework;
};

struct RuntimeContext {
  // Console logs (last N)
  std::vector<ConsoleLog> console_logs;

  // Network requests (recent)
  std::vector<NetworkRequest> network_requests;

  // Errors
  std::vector<Error> errors;

  // Performance
  PerformanceMetrics performance;

  // Terminal output (last N lines)
  std::vector<std::string> terminal_output;
};

struct UserContext {
  // Current mode
  enum Mode { BROWSER, CODE_EDITOR } mode;

  // Active tab
  TabInfo active_tab;

  // All tabs
  std::vector<TabInfo> all_tabs;

  // Recent actions
  std::vector<UserAction> recent_actions;

  // Detected workflow
  std::string workflow_pattern;
};

struct SystemContext {
  // Environment
  std::string os;
  std::string architecture;
  std::string browser_version;

  // Installed tools
  std::vector<InstalledTool> tools;

  // Resources
  ResourceUsage resource_usage;

  // Network
  bool is_online;
};

struct AggregatedContext {
  base::Time timestamp;

  VisualContext visual;
  std::optional<CodeContext> code;  // Only when in code editor
  RuntimeContext runtime;
  UserContext user;
  SystemContext system;
};
```

### Context Service API

```cpp
// components/basedev/context_service/context_api.h

class ContextService {
 public:
  // Get current aggregated context
  AggregatedContext GetCurrentContext();

  // Get specific context category
  VisualContext GetVisualContext();
  CodeContext GetCodeContext();
  RuntimeContext GetRuntimeContext();
  UserContext GetUserContext();
  SystemContext GetSystemContext();

  // Stream context updates
  void SubscribeToContextUpdates(
      base::RepeatingCallback<void(const AggregatedContext&)> callback);

  // Get context at specific time (history)
  std::optional<AggregatedContext> GetContextAtTime(base::Time time);

  // Privacy controls
  void SetPrivacySettings(const PrivacySettings& settings);

  // Serialize for AI
  std::string SerializeForAI(const AggregatedContext& context);
};
```

### Integration with AI Assistant

```cpp
// AI Assistant queries context service

ContextService* context_service = ContextServiceFactory::GetForProfile(profile);

// User asks: "Why is this layout broken?"
AggregatedContext context = context_service->GetCurrentContext();

// AI receives:
// - Screenshot showing broken layout
// - DOM structure
// - CSS computed styles
// - Console errors (if any)
// - Network requests (CSS files loaded?)

std::string context_json = context_service->SerializeForAI(context);
ai_assistant->SendPrompt(user_query, context_json);
```

### Privacy Filtering Example

```cpp
// Automatically filter sensitive data

class ContextFilter {
 public:
  VisualContext FilterVisualContext(const VisualContext& context) {
    VisualContext filtered = context;

    // Blur password fields in screenshot
    if (filtered.screenshot.has_value()) {
      BlurPasswordFields(&filtered.screenshot.value());
    }

    // Remove sensitive input values from DOM
    filtered.dom_snapshot = RemoveSensitiveInputs(filtered.dom_snapshot);

    return filtered;
  }

 private:
  void BlurPasswordFields(SkBitmap* screenshot);
  std::string RemoveSensitiveInputs(const std::string& dom);
};
```

## Dependencies

**Browser Components**:
- Renderer process (DOM, layout, console)
- Network service (network requests)
- DevTools protocol (some context sources)
- Profile system (privacy settings)

**External Libraries**:
- Skia (screenshot rendering)
- JSON library (serialization)
- Compression library (context compression)

## Integration Points

- **AI Assistant**: Primary consumer of context
- **Code Editor**: Source of code context
- **Browser Tabs**: Source of visual/runtime context
- **DevTools**: Alternative context interface
- **Privacy Settings**: User controls

## Testing

### Test Plan

**Unit Tests**:
- [ ] Test each context collector independently
- [ ] Test context aggregation
- [ ] Test serialization/deserialization
- [ ] Test privacy filtering
- [ ] Test context history

**Integration Tests**:
- [ ] Test cross-process context collection
- [ ] Test context updates in real scenarios
- [ ] Test AI Assistant integration
- [ ] Test privacy controls end-to-end

**Performance Tests**:
- [ ] Measure context collection overhead
- [ ] Measure serialization time
- [ ] Measure memory usage
- [ ] Measure network impact (if applicable)

**Privacy Tests**:
- [ ] Verify sensitive data is filtered
- [ ] Test user privacy controls
- [ ] Verify no data leaks

### Test Results
- Status: Not started
- Coverage: 0%
- Issues found: None yet

## Documentation

### Developer Documentation
- Location: `guides/CONTEXT_SERVICE.md` (to be created)
- Content:
  - Architecture overview
  - Adding new context collectors
  - Context data structures
  - API usage
  - Privacy considerations
  - Testing guide

## Related

### References
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [DOM Snapshots](https://developer.mozilla.org/en-US/docs/Web/API/Document)
- [Performance API](https://developer.mozilla.org/en-US/docs/Web/API/Performance)

### Related Features
- AI Assistant with MCP (primary consumer)
- Code Editor (context source)
- Browser (context source)

## Outcomes

### Success Criteria
- Context service collects comprehensive context with <50ms overhead
- Context serialization completes in <100ms
- Privacy filters catch 100% of sensitive data
- AI Assistant queries succeed 99%+ of the time
- Memory overhead <100MB
- No performance regression in browser/editor

### Metrics
- Context collection time: <50ms
- Serialization time: <100ms
- Memory usage: <100MB
- False positive privacy filters: <1%
- False negative privacy filters: 0%
- AI query success rate: >99%

## Next Steps

### Immediate Actions
1. **Design Phase**:
   - [ ] Finalize context data structures
   - [ ] Design collector interfaces
   - [ ] Design privacy filter rules
   - [ ] Plan serialization format

2. **Prototype**:
   - [ ] Implement basic context service
   - [ ] Create one collector (visual context)
   - [ ] Test serialization
   - [ ] Integrate with AI Assistant (mock)

3. **Privacy**:
   - [ ] Research privacy best practices
   - [ ] Design privacy UI
   - [ ] Implement sensitive data detection

### Long-term
- [ ] Move to `progress/past/` when complete
- [ ] Create context visualization tool (for debugging)
- [ ] Context analytics (usage patterns)
- [ ] Machine learning on context patterns

## Notes

### Design Principles

1. **Privacy First**: User data never leaves device without consent
2. **Performant**: Minimal impact on browser performance
3. **Comprehensive**: Rich enough for AI to be truly helpful
4. **Efficient**: Smart about what to collect and when
5. **Secure**: Sensitive data automatically filtered

### Context Collection Strategy

**When to Collect**:
- Continuous: User actions, tabs, workflow
- On-demand: Screenshots, large DOM snapshots
- Periodic: System resources, network status
- Event-driven: Console logs, errors, network requests

**What to Keep**:
- Recent context (last 5 minutes): Full detail
- Historical context (>5 minutes): Summarized
- Session context: Key events only

### Screenshot Optimization

**Strategies**:
- Only capture when AI Assistant explicitly needs it
- Compress before storage/transmission
- Resize to reasonable resolution (e.g., 1920x1080 max)
- Blur sensitive areas (password fields, credit cards)
- Cache for short duration

### Console Log Collection

**Smart Collection**:
- Buffer last 1000 logs
- Keep errors/warnings indefinitely in session
- Filter out spammy logs (configurable)
- Include stack traces for errors
- Track source location (file:line)

### Network Request Monitoring

**What to Capture**:
- URL, method, status code
- Request/response headers (sanitized)
- Timing information
- Size (request/response)
- Initiator (which code triggered it)

**What NOT to Capture**:
- Request/response bodies (too large, may contain sensitive data)
- Authentication tokens
- Cookies (unless user explicitly allows)

### Context Compression

**Techniques**:
- Gzip for text (DOM, logs, etc.)
- Image compression for screenshots
- Delta compression for updates
- Smart pruning of redundant data

### Multi-Tab Context

**Handling Multiple Tabs**:
- Active tab: Full context
- Background tabs: Summary only (URL, title, errors)
- Recently active tabs: Medium detail
- Configurable limit (e.g., context for 5 most recent tabs)

## Questions to Resolve

- [ ] How to handle very large DOMs (millions of nodes)?
- [ ] Screenshot frequency (on-demand vs periodic)?
- [ ] Context retention period?
- [ ] Serialize to JSON or Protocol Buffers?
- [ ] Store context in memory or disk?
- [ ] Context compression strategy?
- [ ] Privacy settings granularity?
- [ ] Context API authentication/authorization?
- [ ] Support for multiple AI consumers?
- [ ] Context replay UI design?

## Resources Needed

- Performance profiling tools
- Privacy expert review
- Large-scale testing infrastructure
- Security audit
- UI/UX for privacy controls
