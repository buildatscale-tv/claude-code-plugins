# Changelog

All notable changes to this project are documented in this file.

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
