#!/bin/bash
# Bash command safety guard for bypass mode
# Blocks dangerous commands BEFORE execution via PreToolUse hook
# Exit 0 = allow, Exit 2 = block with message to stderr

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required for safety hooks but not found. Install with: brew install jq" >&2
  exit 2
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Normalize: lowercase, collapse whitespace
cmd_lower=$(echo "$command" | tr '[:upper:]' '[:lower:]' | tr -s ' ')

# === BLOCKED PATTERNS ===

# 1. Destructive recursive operations on root or home
if echo "$cmd_lower" | grep -qE 'rm\s+-[rf]*\s+(/|~|\$home|/users|/home|/var|/etc|/usr|/bin|/sbin)'; then
  echo "BLOCKED: Destructive operation on system directory - use ! to override" >&2
  exit 2
fi

# 2. sudo commands (should be explicit)
if echo "$cmd_lower" | grep -qE '^\s*sudo\s'; then
  echo "BLOCKED: sudo requires explicit approval - use ! to override" >&2
  exit 2
fi

# 3. Credential/secret file access
if echo "$cmd_lower" | grep -qE '(cat|less|head|tail|read|cp|mv|scp).*(/\.ssh/|/\.aws/|/\.gnupg/|/\.netrc|credentials|\.env\b|secrets?\.)'; then
  echo "BLOCKED: Accessing credential/secret files - use ! to override" >&2
  exit 2
fi

# 4. System modification
if echo "$cmd_lower" | grep -qE '(chown|chmod)\s+.*(/etc|/usr|/bin|/var)'; then
  echo "BLOCKED: System file permission changes - use ! to override" >&2
  exit 2
fi

# 5. Dangerous curl/wget piped to shell
if echo "$cmd_lower" | grep -qE '(curl|wget).*\|\s*(bash|sh|zsh|python|node)'; then
  echo "BLOCKED: Piping remote content to shell is dangerous - use ! to override" >&2
  exit 2
fi

# 6. npm/yarn/bun global installs (should be explicit)
if echo "$cmd_lower" | grep -qE '(npm|yarn|pnpm)\s+(install|i)\s+(-g|--global)'; then
  echo "BLOCKED: Global package installs require manual approval - use ! to override" >&2
  exit 2
fi

# 7. Disk/system commands
if echo "$cmd_lower" | grep -qE '^\s*(mkfs|fdisk|dd\s+if=|diskutil\s+erase)'; then
  echo "BLOCKED: Disk manipulation commands - use ! to override" >&2
  exit 2
fi

# 8. Process killing (system processes)
if echo "$cmd_lower" | grep -qE 'kill(all)?\s+(-9\s+)?-1\b|pkill\s+-9\s+'; then
  echo "BLOCKED: Mass process termination - use ! to override" >&2
  exit 2
fi

# 9. Network exfiltration patterns
if echo "$cmd_lower" | grep -qE '(curl|wget|nc|netcat).*(-d|--data|<)\s*.*(\$|`|/etc/|/users/|/home/)'; then
  echo "BLOCKED: Potential data exfiltration pattern - use ! to override" >&2
  exit 2
fi

# 10. Eval/exec of dynamic content
if echo "$cmd_lower" | grep -qE 'eval\s+"\$|bash\s+-c\s+"\$'; then
  echo "BLOCKED: Dynamic code execution - use ! to override" >&2
  exit 2
fi

# 11. Cron/scheduled task modification
if echo "$cmd_lower" | grep -qE '(crontab\s+-|launchctl\s+(load|unload|submit))'; then
  echo "BLOCKED: Scheduled task modification requires manual approval - use ! to override" >&2
  exit 2
fi

# 12. SSH key generation/modification
if echo "$cmd_lower" | grep -qE 'ssh-keygen|ssh-add'; then
  echo "BLOCKED: SSH key operations require manual approval - use ! to override" >&2
  exit 2
fi

# 13. Keychain/credential store access
if echo "$cmd_lower" | grep -qE 'security\s+(find|delete|add)-(generic|internet)-password|keychain'; then
  echo "BLOCKED: Keychain access - use ! to override" >&2
  exit 2
fi

# 14. Environment variable dumps that might leak secrets
if echo "$cmd_lower" | grep -qE '^\s*(env|printenv|export)\s*$|set\s*\|'; then
  echo "BLOCKED: Full environment dump may leak secrets. Use specific vars instead - use ! to override" >&2
  exit 2
fi

# === ALLOWED ===
exit 0
