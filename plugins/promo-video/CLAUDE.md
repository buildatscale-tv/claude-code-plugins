# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Promo Video is a Claude Code plugin/skill for creating professional promotional videos using Remotion with AI voiceover and background music. It guides you through a 5-phase workflow: understanding the product, choosing duration and theme, building with Remotion, generating voiceover with ElevenLabs, and mixing music for final render.

## Prerequisites

- **Node.js** (18+) for Remotion video creation
- **Python 3.x** for voiceover generation script
- **ffmpeg** installed for audio/video processing
- **`ELEVEN_LABS_API_KEY`** environment variable for ElevenLabs voiceover
- **Whisper** (optional but recommended) for voiceover timing verification
- **`remotion-best-practices` skill** installed (`npx skills add remotion-dev/skills`)

## Architecture

```
promo-video/
├── CLAUDE.md                     # This file
└── skills/
    └── promo-video/
        ├── SKILL.md              # Skill definition and 5-phase workflow
        ├── promo-patterns.md     # Visual inspiration and animation techniques
        ├── voiceover.md          # Voiceover generation and timing guide
        ├── metallic-swoosh.md    # Metallic shine transition implementation
        ├── scripts/
        │   └── generate_voiceover.py  # ElevenLabs voiceover generation
        └── music/                # Bundled royalty-free tracks (Pixabay)
            ├── inspired-ambient-141686.mp3
            ├── motivational-day-112790.mp3
            └── the-upbeat-inspiring-corporate-142313.mp3
```

The plugin follows Claude Code's skill structure where `SKILL.md` defines the skill metadata and provides the full creative workflow. The Python script uses the ElevenLabs API for voiceover generation with Whisper-based timing verification.
