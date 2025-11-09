# Progress Tracking

Feature-based progress tracking for Base Browser development.

## Directory Structure

```
progress/
├── past/       # Completed features and milestones
├── current/    # Features actively being developed
├── future/     # Planned features and roadmap
└── README.md   # This file
```

## Usage

### Adding a New Feature

1. **Create feature file** in `current/`:
   ```bash
   cp progress/TEMPLATE.md progress/current/feature-name.md
   ```

2. **Fill in the details**:
   - Feature description
   - Technical approach
   - Progress updates
   - Blockers/challenges

3. **Move when complete**:
   ```bash
   mv progress/current/feature-name.md progress/past/
   ```

### Planning Future Features

Create feature files in `future/` directory with preliminary research and requirements.

## Naming Convention

- Use lowercase with hyphens: `feature-name.md`
- Be descriptive: `side-panel-generator.md`, `custom-branding.md`
- Prefix with category if helpful: `ui-dark-mode.md`, `build-python-compatibility.md`

## Template

Copy `TEMPLATE.md` for new features. It includes:
- Metadata (status, dates, contributors)
- Feature overview
- Technical details
- Implementation notes
- Progress tracking
- Outcomes/learnings

## Current Status

See individual files in each directory for detailed status.

Quick overview:
```bash
# List all features by status
ls -1 progress/past/
ls -1 progress/current/
ls -1 progress/future/
```

## Integration with Development

- Features should reference:
  - Related patches in `patches/ungoogled-chromium/`
  - Documentation in `guides/`
  - Tools in `tools/`
  - Build scripts in `scripts/`

## See Also

- [MAP.md](../MAP.md) - Repository structure
- [guides/](../guides/) - Development guides
- [tools/](../tools/) - Development tools
