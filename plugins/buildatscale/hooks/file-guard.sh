#!/bin/bash
# File operation safety guard for bypass mode
# Blocks writes to dangerous paths via PreToolUse hook
# Exit 0 = allow, Exit 2 = block with message to stderr

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required for safety hooks but not found. Install with: brew install jq" >&2
  exit 2
fi

input=$(cat)
# Single jq call to extract both fields (faster than multiple Python invocations)
eval "$(echo "$input" | jq -r '@sh "tool_name=\(.tool_name // "") file_path=\(.tool_input.file_path // "")"' 2>/dev/null)"

# Normalize path
path_lower=$(echo "$file_path" | tr '[:upper:]' '[:lower:]')

# === BLOCKED PATHS ===

# 1. System directories
if echo "$path_lower" | grep -qE '^(/etc/|/usr/|/bin/|/sbin/|/var/|/lib/|/boot/)'; then
  echo "BLOCKED: Cannot write to system directory: $file_path - use ! to override" >&2
  exit 2
fi

# 2. Home directory config files (outside project)
if echo "$path_lower" | grep -qE '^(/users/[^/]+|~|/home/[^/]+)/\.(ssh|aws|gnupg|config|zshrc|bashrc|profile|netrc)'; then
  echo "BLOCKED: Cannot modify user config files: $file_path - use ! to override" >&2
  exit 2
fi

# 3. Credential files
if echo "$path_lower" | grep -qE '(credentials|secrets?\.json|\.env$|\.pem$|\.key$|id_rsa|id_ed25519)'; then
  # Allow .env.example or .env.local within project
  if echo "$file_path" | grep -qE '\.env\.(example|sample|template)$'; then
    exit 0
  fi
  # Check if in project directory (CLAUDE_PROJECT_DIR)
  if [[ -n "$CLAUDE_PROJECT_DIR" ]] && [[ "$file_path" == "$CLAUDE_PROJECT_DIR"* ]]; then
    # Allow .env files in project, but warn
    if echo "$path_lower" | grep -qE '\.env$'; then
      exit 0  # Allow project .env files
    fi
  fi
  echo "BLOCKED: Cannot write credential/secret file: $file_path - use ! to override" >&2
  exit 2
fi

# 4. Package manager config (outside project)
if echo "$path_lower" | grep -qE '^(/users/|~|/home/).*(\.npmrc|\.yarnrc|\.bunfig)'; then
  echo "BLOCKED: Cannot modify global package manager config: $file_path - use ! to override" >&2
  exit 2
fi

# 5. Git global config
if echo "$path_lower" | grep -qE '^(/users/|~|/home/)[^/]+/\.gitconfig$'; then
  echo "BLOCKED: Cannot modify global git config: $file_path - use ! to override" >&2
  exit 2
fi

# 6. Shell history
if echo "$path_lower" | grep -qE '\.(bash_history|zsh_history|history)$'; then
  echo "BLOCKED: Cannot modify shell history: $file_path - use ! to override" >&2
  exit 2
fi

# 7. Launchd/cron
if echo "$path_lower" | grep -qE '(launchagents|launchdaemons|cron)'; then
  echo "BLOCKED: Cannot modify scheduled tasks: $file_path - use ! to override" >&2
  exit 2
fi

# === ALLOWED ===
exit 0
