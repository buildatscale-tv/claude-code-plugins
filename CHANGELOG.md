# Changelog

All notable changes to this project are documented in this file.

## 1.4.1 - 2026-02-10

### BuildAtScale Core

- Enforced 70-character hard max on commit messages in `/buildatscale:commit` (GitHub truncates beyond 72)
- Refined bullet points in CEO summary for clarity

## 1.4.0 - 2026-02-02

### BuildAtScale Core

- Added `statusline.sh` - Enhanced status line hook with context runway gauge
  - Shows remaining context percentage instead of used (runway gauge mode)
  - Color-coded warnings with `--color-usage` flag (green/yellow/red) or `--color-usage warnings` (yellow/red only)
  - Configurable thresholds: `--usage-warning <pct>` and `--usage-critical <pct>` (defaults: 25/10)
  - Full bar turns red at critical level
  - Git branch display with relative path when in subdirectories
  - Configurable cost display for API users
  - Uses `remaining_percentage` from Claude Code JSON when available for accuracy
  - CLI flags: `--cost`, `--display`, `--detail`, `--color-usage`, `--usage-warning`, `--usage-critical`, `--no-color`
  - Handles null context data gracefully

## 1.3.2 - 2026-02-01

### Safety Hooks

- Added `jq` dependency check to all safety hooks to prevent silent failures when `jq` is not installed

## 1.3.1 - 2026-02-01

### Bug Fixes

- Fixed missing execute permissions on `git-block-force-push.sh`, `bash-guard.sh`, and `file-guard.sh` hook scripts

## 1.3.0 - 2026-02-01

### Safety Hooks

- Added `bash-guard` hook to validate bash commands before execution
- Added `file-guard` hook to protect sensitive files from modifications
- Renamed `block-force-git` to `git-block-force-push`

## 1.2.0 - 2026-01-27

### Promo Video

- Added promo-video plugin for creating promotional videos using Remotion with AI voiceover and background music

## 1.1.0 - 2026-01-14

### Nano Banana Pro

- Added `--model` flag to select between Gemini models: `flash` (default, fast) or `pro` (high-quality)
- Added `--size` flag for pro model resolution: `1K` (default), `2K`, `4K`
- Added CLAUDE.md with plugin documentation

Thanks to [@gscalzo](https://github.com/gscalzo) for contributing model selection support!

## 2026-01-04

### Bug Fixes

- Fixed force-push hook to only match actual git commands (not strings containing "git")
- Fixed file permissions on block-force-push hook script

## 2025-12-27

### Nano Banana Pro

- Added optional `--reference` flag for style/composition guidance from existing images
- Improved skill description with more keywords for better discoverability

## 2025-12-19

### Project Structure

- Reorganized plugins into dedicated directories (`plugins/buildatscale`, `plugins/nano-banana-pro`)
- Moved commands (ceo, commit, pr) and hooks into buildatscale plugin
- Updated marketplace.json structure for individual skill installation

## 2025-12-11

### Documentation

- Added video links demonstrating plugin usage
- Improved README with clearer terminology and prerequisites
- Updated to use "slash commands" terminology

## 2025-12-09

### Nano Banana Pro

- Added nano-banana-pro skill for AI image generation using Google's Gemini models
- Supports prompt-based image generation with configurable aspect ratios (square, landscape, portrait)
- Integrates with frontend-design workflows

### Project Setup

- Added README with installation instructions
- Added .gitignore for local Claude settings and Python cache
- Restructured marketplace.json for individual skill installation

## 1.0.0 - 2025-10-13

### Initial Release

- Added `/commit` command for creating well-formatted git commits
- Added `/pr` command for creating pull requests with GitHub CLI
- Added `/ceo` command for generating executive summaries
- Added `block-force-git` hook to prevent accidental force pushes
- Added `file-write-cleanup` hook for post-write file cleanup
