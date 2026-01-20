# BuildAtScale Claude Code Plugins

Claude Code plugins from BuildAtScale - slash commands, hooks, and skills for enhanced productivity.

## Quick Start

### Add the Marketplace

```bash
/plugin marketplace add https://github.com/buildatscale-tv/claude-code-plugins
```

### Install Plugins

**Core features (slash commands and hooks):**
```bash
/plugin install buildatscale@buildatscale-claude-code
```

**Image generation skill:**
```bash
/plugin install nano-banana-pro@buildatscale-claude-code
```

## Available Plugins

### buildatscale (Core Tools)

Core slash commands and hooks for git workflow automation.

**Slash Commands:**
- `/buildatscale:commit` - Create commit message(s) for staged/unstaged changes, breaking into logical units
- `/buildatscale:pr` - Create pull request with GitHub CLI, auto-branching from main/master
- `/buildatscale:ceo` - Create executive summary of work in progress, recent work, or recently deployed changes

**Hooks:**
- `block-force-git.sh` - Prevents dangerous git operations like force push
- `file-write-cleanup.sh` - Cleans up files after write/edit operations

**Scripts:**
- `statusline.sh` - Enhanced status line with context runway gauge (see below)

#### Statusline Setup

The statusline hook provides an enhanced status display with:
- **Context runway gauge** - Shows remaining context (not used), so you know how much runway you have left
- **Color-coded warnings** - Green (OK) → Yellow (<25% remaining) → Red (<10% remaining, compaction imminent)
- **Git branch display** - Current branch in green
- **Relative path display** - Shows `./project/subdir` when in subdirectories
- **Configurable cost display** - Toggle on/off for API users

**Example output:**
```
[./website/src][main]              +156/-23 | ████████████░░░░░░░░ 58% | Opus
```

**To enable**, add to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/plugins/marketplaces/buildatscale-claude-code/plugins/buildatscale/scripts/statusline.sh"
  }
}
```

> **Note:** Status line is configured as a top-level setting, not through the plugin system. This must be added manually after installing the plugin.

**Configuration** (edit the script to customize):
- `SHOW_COST=false` - Set to `true` to display session cost (useful for API users)
- `CONTEXT_DISPLAY="remaining"` - Set to `"used"` for classic fill-up bar instead of runway gauge

### nano-banana-pro (Skill)

Generate images using Google's Gemini 2.5 Flash (Nano Banana Pro). See the [demo video](https://youtu.be/MNqUedk79IY).

**Triggers:** `gemini`, `image-generation`, `ai`, `frontend`, `design`, `visual-assets`

**Prerequisites:**
- [uv](https://docs.astral.sh/uv/) - Python package manager (required to run the image generation script). See the [uv installation walkthrough](https://youtu.be/DRdd4V1G4-k?t=80)
- `GEMINI_API_KEY` environment variable with your Google AI API key

**Usage:**
```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "Your image description" \
  --output "/path/to/output.png" \
  --aspect landscape  # optional: square, landscape, portrait
```

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json        # Plugin registry
└── plugins/
    ├── buildatscale/
    │   ├── commands/
    │   │   ├── ceo.md          # /buildatscale:ceo command
    │   │   ├── commit.md       # /buildatscale:commit command
    │   │   └── pr.md           # /buildatscale:pr command
    │   ├── hooks/
    │   │   ├── block-force-git.sh
    │   │   └── file-write-cleanup.sh
    │   └── scripts/
    │       └── statusline.sh
    └── nano-banana-pro/
        └── skills/
            └── generate/
                ├── SKILL.md    # Skill documentation
                └── scripts/
                    └── image.py
```

## License

MIT
