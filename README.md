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

**Promo video creation skill:**
```bash
/plugin install promo-video@buildatscale-claude-code
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

### promo-video (Skill)

Create professional promotional videos using Remotion with AI voiceover and background music. Invoke with `/promo-video`. Guides you through a 5-phase workflow: product analysis, theme selection, Remotion build, voiceover generation, and final render with music.

**Prerequisites:**
- [Node.js](https://nodejs.org/) (18+) - Required for Remotion video creation
- [Python 3.x](https://www.python.org/) - Required for voiceover generation script
- [ffmpeg](https://ffmpeg.org/) - Required for audio/video processing (`brew install ffmpeg`)
- `ELEVEN_LABS_API_KEY` environment variable with your [ElevenLabs](https://elevenlabs.io/) API key
- [Whisper](https://github.com/openai/whisper) (optional but recommended) - For voiceover timing verification (`pip install openai-whisper`)
- `remotion-best-practices` skill installed (`npx skills add remotion-dev/skills`)

**What it creates:**
- 1920x1080 full HD promotional videos
- AI-generated voiceover synced to on-screen visuals
- Background music mixing with fade in/out
- Professional transitions (metallic swoosh, zoom through, fade, slide)

**Included resources:**
- 3 royalty-free background music tracks (Pixabay)
- ElevenLabs voiceover generation script with Whisper timing verification
- Metallic swoosh transition implementation
- Visual design patterns and animation techniques

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
    ├── nano-banana-pro/
    │   └── skills/
    │       └── generate/
    │           ├── SKILL.md    # Skill documentation
    │           └── scripts/
    │               └── image.py
    └── promo-video/
        ├── CLAUDE.md           # Plugin documentation
        └── skills/
            └── promo-video/
                ├── SKILL.md              # 5-phase workflow guide
                ├── promo-patterns.md     # Visual inspiration
                ├── voiceover.md          # Voiceover generation guide
                ├── metallic-swoosh.md    # Transition implementation
                ├── scripts/
                │   └── generate_voiceover.py
                └── music/
                    ├── inspired-ambient-141686.mp3
                    ├── motivational-day-112790.mp3
                    └── the-upbeat-inspiring-corporate-142313.mp3
```

## License

MIT
