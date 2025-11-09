# Weekend Implementation Plan (Nov 9-11, 2025)

## Overview
Implement three major features autonomously while user is away, creating branches for each feature to preserve progress.

## Feature Priority & Timeline

### Feature 1: AI Assistant Sidepanel (Saturday Morning)
**Branch**: `feature/ai-assistant-sidepanel`
**Estimated Time**: 4-6 hours

**Implementation Steps**:
1. Move `progress/future/ai-assistant-with-mcp.md` → `progress/current/`
2. Create feature branch
3. Generate sidepanel using `./tools/sidepanel.sh AIAssistant`
4. Implement basic chat UI (HTML/CSS/TS)
5. Add context indicator (Browser vs Code Editor mode)
6. Create mock AI backend (later connect to real AI)
7. Build and test
8. Commit and push branch

**Deliverables**:
- chrome://basedev-aiassistant-side-panel/ working
- Basic chat interface functional
- Context switching logic implemented
- Tests passing

### Feature 2: Code Editor with Monaco (Saturday Afternoon)
**Branch**: `feature/code-editor-monaco`
**Estimated Time**: 6-8 hours

**Implementation Steps**:
1. Move `progress/future/integrated-code-editor.md` → `progress/current/`
2. Create feature branch
3. Create chrome://code/ WebUI
4. Integrate Monaco Editor
5. Implement file explorer sidebar
6. Add basic file operations (open, save, create, delete)
7. Implement integrated terminal (basic shell execution)
8. Add syntax highlighting and basic code intelligence
9. Build and test
10. Commit and push branch

**Deliverables**:
- chrome://code/ accessible
- Monaco Editor loading and working
- File explorer showing directory structure
- Terminal functional
- Basic file operations working

### Feature 3: Login with Base OAuth (Sunday Morning)
**Branch**: `feature/login-with-base`
**Estimated Time**: 4-6 hours

**Implementation Steps**:
1. Move `progress/future/login-with-base.md` → `progress/current/`
2. Create feature branch
3. Create OAuth flow (accounts.base.al integration)
4. Implement profile creation on login
5. Add secure token storage
6. Create login UI
7. Test OAuth flow
8. Build and test
9. Commit and push branch

**Deliverables**:
- Login with Base button working
- OAuth flow complete
- Profile creation on login
- Token storage secure
- Logout functionality

## Testing Strategy

**For Each Feature**:
1. Generate feature branch
2. Implement feature
3. Run incremental build: `cd ungoogled-chromium/build/src && ninja -C out/Default chrome`
4. Test manually in browser
5. Document any issues
6. Commit with detailed message
7. Create backup of build: `cp -R out/Default/Base\ Dev.app ../../../../binaries/backups/Base\ Dev.app.{feature}-{date}`
8. Push branch to GitHub

## Branch Strategy

```
main (protected - working branding)
├── feature/ai-assistant-sidepanel (AI sidepanel implementation)
├── feature/code-editor-monaco (Code editor with Monaco)
└── feature/login-with-base (OAuth integration)
```

**After All Features Complete**:
- Merge to main one by one after user testing
- Create integration branch if needed
- Tag releases for each feature

## Agents to Spawn

### Agent 1: AI Sidepanel Implementation
**Type**: general-purpose
**Task**: 
- Generate sidepanel using tools/sidepanel.sh
- Implement basic chat UI
- Add context switching
- Create mock AI backend
- Test and verify functionality

### Agent 2: Monaco Editor Integration
**Type**: general-purpose
**Task**:
- Create chrome://code/ WebUI
- Integrate Monaco Editor
- Implement file explorer
- Add terminal integration
- Test file operations

### Agent 3: OAuth Implementation
**Type**: general-purpose
**Task**:
- Implement OAuth flow
- Create login UI
- Add token storage
- Test authentication flow

## Build Monitoring

Monitor these background builds:
- 502158: Earlier branding build
- ed6124: String changes build
- 132d5a: Assets.car rebuild

Kill completed builds before starting new feature builds.

## Success Criteria

**By Monday Morning**:
- [x] 3 feature branches created and pushed
- [x] AI Assistant sidepanel working (basic chat)
- [x] Code Editor with Monaco functional
- [x] Login with Base OAuth flow complete
- [x] All features tested individually
- [x] Documentation updated for each feature
- [x] Build backups created for each feature

## Rollback Plan

If any feature breaks the build:
1. Abandon that feature branch
2. Document issues in progress/ file
3. Move to next feature
4. Return to main branch for stable base

## Communication

Create detailed commit messages and update progress/ files so user can:
- Review all changes when they return
- Understand what was implemented
- Test each feature independently
- Decide on merge strategy

## Notes

- Work autonomously but document everything
- Test incrementally after each major change
- Don't merge to main - let user test first
- Create backups frequently
- Use TodoWrite to track all tasks
- Spawn agents for parallel work where possible
