# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Nano Banana Pro is a Claude Code plugin/skill for generating images using Google's Gemini models (Flash for speed, Pro for quality). It integrates as a skill that can be invoked via `/generate` or triggered by image generation requests.

## Running the Image Generation Script

```bash
uv run skills/generate/scripts/image.py \
  --prompt "Your image description" \
  --output "/path/to/output.png"
```

Options:
- `--prompt` (required): Image description
- `--output` (required): Output file path (PNG)
- `--aspect` (optional): `square` (default), `landscape`, `portrait`
- `--reference` (optional): Path to reference image for style guidance
- `--model` (optional): `flash` (default, fast) or `pro` (high-quality, up to 4K)
- `--size` (optional): `1K` (default), `2K`, `4K` - resolution for pro model only

## Prerequisites

- `GEMINI_API_KEY` environment variable must be set with a Google AI API key
- Python 3.10+ with `uv` package manager
- Dependencies (`google-genai`, `pillow`) are managed via inline script metadata

## Architecture

```
nano-banana-pro/
├── skills/
│   └── generate/
│       ├── SKILL.md          # Skill definition and usage docs
│       └── scripts/
│           └── image.py      # Main image generation script
└── .claude/
    └── settings.local.json   # Claude Code permission settings
```

The plugin follows Claude Code's skill structure where `SKILL.md` defines the skill metadata (name, description, triggers) and provides usage instructions. The Python script uses Google's GenAI SDK with inline PEP 723 dependencies for zero-config execution via `uv run`.
