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

### nano-banana-pro (Skill)

Generate images using Google's Gemini models (Nano Banana Pro). See the [demo video](https://youtu.be/MNqUedk79IY).

**Available Models:**
| Model | Best For | Max Resolution |
|-------|----------|----------------|
| **Flash** (default) | Speed, high-volume tasks | 1024px |
| **Pro** | Professional quality, complex scenes | Up to 4K |

**Prerequisites:**
- [uv](https://docs.astral.sh/uv/) - Python package manager (required to run the image generation script). See the [uv installation walkthrough](https://youtu.be/DRdd4V1G4-k?t=80)
- `GEMINI_API_KEY` environment variable with your Google AI API key

**Usage:**
```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "Your image description" \
  --output "/path/to/output.png"
```

**Options:**
- `--prompt` (required): Image description
- `--output` (required): Output file path (PNG)
- `--aspect`: Aspect ratio - `square` (default), `landscape`, `portrait`
- `--reference`: Path to a reference image for style guidance
- `--model`: `flash` (default, fast) or `pro` (high-quality)
- `--size`: Resolution for pro model - `1K` (default), `2K`, `4K`

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
    │   └── hooks/
    │       ├── block-force-git.sh
    │       └── file-write-cleanup.sh
    └── nano-banana-pro/
        └── skills/
            └── generate/
                ├── SKILL.md    # Skill documentation
                └── scripts/
                    └── image.py
```

## License

MIT
