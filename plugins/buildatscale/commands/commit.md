---
allowed-tools: Bash(git status), Bash(git diff), Bash(git log), Bash(git add), Bash(git commit), Bash(git branch), Bash(git checkout)
description: Create commit message(s) for staged/unstaged changes, breaking into logical units
---

I need to create a commit (or multiple commits) for the current changes. Let me analyze the repository state and create appropriate commit messages following the user's guidelines.

First, let me check the current branch and status:

! git branch --show-current
! git status

If I'm on main or master and there are changes, I'll create a descriptive kebab-case branch first (preferred: 2 words, max: 3 words) based on the nature of the changes:

! CURRENT_BRANCH=$(git branch --show-current)
! if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]] && [[ $(git status --porcelain) ]]; then echo "On main/master with changes - will create feature branch after analyzing changes"; fi

Now let me see what changes are staged and unstaged:

! git diff --cached
! git diff

Let me also check recent commit history to understand the style:

! git log --oneline -10

Based on the changes, I'll determine if this represents:
1. A single logical unit of change → create one commit
2. Multiple distinct changes → break into separate commits with focused messages

I'll follow the commit message guidelines:
- **70 characters or less** (hard max: 72 — GitHub truncates beyond this)
- Use imperative mood
- Start with action verbs
- Omit articles
- No punctuation at end
- Single-line descriptions
- If a message is approaching 70 chars, cut filler words rather than exceed the limit

For each commit, I'll:
1. Stage the appropriate files for that logical unit
2. Create a commit with a focused message
3. Repeat for additional logical units if needed

Let me proceed with creating the commit(s).
