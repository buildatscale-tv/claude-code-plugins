# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Nano Banana is a Claude Code plugin/skill for generating images using Google's Gemini models (Flash for speed, Pro for quality, Nano Banana 2 for fast high-res). It integrates as a skill that can be invoked via `/generate` or triggered by image generation requests.

## Running the Image Generation Script

```bash
uv run skills/generate/scripts/image.py \
  --prompt "Your image description" \
  --output "/path/to/output.png"
```

Options:
- `--prompt` (required): Image description
- `--output` (required): Output file path (PNG)
- `--aspect` (optional): Named shortcut (`square`, `landscape`, `portrait`) or direct ratio (e.g. `4:3`, `16:9`, `21:9`). Default: square
- `--reference` (optional, repeatable): Path to reference image for style guidance. Use multiple times for multiple references.
- `--model` (optional): `flash` (fast, 1024px), `pro` (high-quality, up to 4K), or `2` (default, Nano Banana 2, fast + up to 4K)
- `--size` (optional): `512` (model 2 only), `1K` (default), `2K`, `4K` - resolution for pro/2 models only

## Prerequisites

- `GEMINI_API_KEY` environment variable must be set with a Google AI API key
- Python 3.10+ with `uv` package manager
- Dependencies (`google-genai`, `pillow`) are managed via inline script metadata

## Architecture

```
nano-banana/
├── skills/
│   └── generate/
│       ├── SKILL.md          # Skill definition and usage docs
│       └── scripts/
│           └── image.py      # Main image generation script
└── .claude/
    └── settings.local.json   # Claude Code permission settings
```

The plugin follows Claude Code's skill structure where `SKILL.md` defines the skill metadata (name, description, triggers) and provides usage instructions. The Python script uses Google's GenAI SDK with inline PEP 723 dependencies for zero-config execution via `uv run`.
