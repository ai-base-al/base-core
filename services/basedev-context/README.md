# BaseRev Context Service

Go backend service for the AI Assistant sidepanel. Provides context awareness, framework detection, and manages MCP/LSP servers.

## Features

- **Context Detection**: Determines if user is in browser or code editor mode
- **Framework Detection**: Automatically detects project frameworks (Nuxt, Next.js, Go, Flutter, Base)
- **MCP Server Management**: Manages Model Context Protocol servers (placeholder)
- **LSP Server Management**: Manages Language Server Protocol servers (placeholder)
- **REST API**: Provides HTTP endpoints for frontend integration

## API Endpoints

### GET /api/context
Returns current context information:
```json
{
  "mode": "browser" | "code_editor",
  "framework": "Nuxt" (optional)
}
```

### POST /api/chat
Sends a message to the AI assistant:
```json
{
  "message": "user message",
  "context": {
    "mode": "browser",
    "framework": "Nuxt"
  },
  "history": [...]
}
```

Response:
```json
{
  "response": "AI assistant response"
}
```

### GET /health
Health check endpoint:
```json
{
  "status": "healthy",
  "service": "basedev-context"
}
```

## Running

```bash
cd services/basedev-context
go run main.go
```

Server starts on `http://localhost:8765`

## Building

```bash
go build -o basedev-context
./basedev-context
```

## Future Enhancements

1. **Real Framework Detection**: Scan actual project directories
2. **MCP Server Integration**: Spawn and manage real MCP servers
3. **LSP Server Integration**: Spawn and manage real LSP servers
4. **AI Model Integration**: Connect to actual AI models (local or cloud)
5. **Framework Registry**: Fetch framework definitions from base.al
6. **File System Access**: Read project files for better context
7. **Terminal Integration**: Execute commands and capture output

## Architecture

```
services/basedev-context/
├── main.go                 # HTTP server and API handlers
├── framework/
│   └── detector.go         # Framework detection logic
├── mcp/
│   └── manager.go          # MCP server lifecycle management
├── lsp/
│   └── manager.go          # LSP server lifecycle management
├── go.mod                  # Go module definition
└── README.md              # This file
```

## Integration with Browser

The browser's AI Assistant sidepanel connects to this service via HTTP on localhost:8765. The frontend polls `/api/context` every 5 seconds to update the context indicator and sends chat messages to `/api/chat`.

## Security

- Service only listens on localhost (not exposed externally)
- CORS enabled for browser integration
- No authentication required (local-only service)
- Future: Add authentication tokens if needed
