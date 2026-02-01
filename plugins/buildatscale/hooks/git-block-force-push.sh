#!/bin/bash

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required for safety hooks but not found. Install with: brew install jq" >&2
  exit 2
fi

# Read JSON input from stdin
input=$(cat)

# Extract tool name and command from JSON
tool_name=$(echo "$input" | jq -r '.tool_name // ""' 2>/dev/null)
command=$(echo "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Block git commands with force flags (only commands starting with 'git ')
if [[ "$tool_name" == "Bash" && "$command" =~ ^git[[:space:]].*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)) ]]; then
    echo "ERROR: Force push blocked by hook - use ! if needed" >&2
    exit 2
fi

exit 0
