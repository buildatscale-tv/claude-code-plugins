---
allowed-tools: Bash(git status), Bash(git diff), Bash(git log), Bash(git checkout), Bash(git push), Bash(gh pr create)
description: Create pull request with GitHub CLI, auto-branching from main/master
---

I'll create a pull request for the current changes. Let me first check the repository state and determine if I need to create a new branch.

First, let me check what branch we're currently on and the repository status:

! git branch --show-current
! git status

Let me see what changes will be included in the PR:

! git diff main...HEAD 2>/dev/null || git diff master...HEAD 2>/dev/null || git diff HEAD~1..HEAD
! git log --oneline main..HEAD 2>/dev/null || git log --oneline master..HEAD 2>/dev/null || git log --oneline -5

Now I'll check that we're on a feature branch and not on main/master:

! CURRENT_BRANCH=$(git branch --show-current)
! if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then echo "ERROR: Cannot create PR from main/master branch. Use /commit first to create a feature branch." >&2; exit 1; fi

Great! We're on a feature branch and ready to create the PR.

Once the branch is ready, I'll push it and create the PR:

! git push -u origin $(git branch --show-current)

Finally, I'll create the pull request with an appropriate title and description. I'll analyze the changes to determine if test steps are warranted:

! gh pr create --title "$(git log --oneline -1 --pretty=format:'%s')" --body "$(cat <<'EOF'
## Summary
- [Brief bullet points describing the key changes]

[Include test plan section only if the changes warrant testing steps]
EOF
)"

The pull request has been created successfully!