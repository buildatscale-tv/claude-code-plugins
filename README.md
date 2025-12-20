# BuildAtScale Claude Code Plugins

Claude Code plugins from BuildAtScale - commands, hooks, and skills for enhanced productivity.

## Quick Start

### Add the Marketplace

```bash
/plugin marketplace add https://github.com/buildatscale-tv/claude-code-plugins
```

### Install Plugins

**Install everything (commands, hooks, and skills):**
```bash
/plugin install buildatscale@buildatscale-claude-code
```

**Install individual skills:**
```bash
/plugin install nano-banana-pro@buildatscale-claude-code
```

## Available Plugins

### buildatscale (Core Tools)

Core commands and hooks for git workflow automation.

**Commands:**
- `/buildatscale:commit` - Create commit message(s) for staged/unstaged changes, breaking into logical units
- `/buildatscale:pr` - Create pull request with GitHub CLI, auto-branching from main/master
- `/buildatscale:ceo` - Create executive summary of work in progress, recent work, or recently deployed changes

**Hooks:**
- `block-force-git.sh` - Prevents dangerous git operations like force push
- `file-write-cleanup.sh` - Cleans up files after write/edit operations

### nano-banana-pro (Skill)

Generate images using Google's Gemini 2.5 Flash for frontend designs.

**Triggers:** `gemini`, `image-generation`, `ai`, `frontend`, `design`, `visual-assets`

**Prerequisites:** Set the `GEMINI_API_KEY` environment variable with your Google AI API key.

**Usage:**
```bash
uv run "${SKILL_DIR}/scripts/generate_image.py" \
  --prompt "Your image description" \
  --output "/path/to/output.png" \
  --aspect landscape  # optional: square, landscape, portrait
```

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json        # Plugin registry
├── plugins/
│   └── buildatscale/
│       ├── commands/
│       │   ├── ceo.md          # /buildatscale:ceo command
│       │   ├── commit.md       # /buildatscale:commit command
│       │   └── pr.md           # /buildatscale:pr command
│       └── hooks/
│           ├── block-force-git.sh
│           └── file-write-cleanup.sh
└── skills/
    └── nano-banana-pro/
        ├── SKILL.md            # Skill documentation
        └── scripts/
            └── generate_image.py
```

## License

MIT
