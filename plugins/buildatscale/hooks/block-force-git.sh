#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract tool name and command from JSON
tool_name=$(echo "$input" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_name', ''))")
command=$(echo "$input" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('command', ''))")

# Block git commands with force flags (only commands starting with 'git ')
if [[ "$tool_name" == "Bash" && "$command" =~ ^git[[:space:]].*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)) ]]; then
    echo "ERROR: Force push blocked by hook - use ! if needed" >&2
    exit 2
fi

exit 0
