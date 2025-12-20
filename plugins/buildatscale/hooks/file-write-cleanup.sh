#!/bin/bash

# File write hook that:
# 1. Removes lines that contain only whitespace (spaces/tabs)
# 2. Ensures file ends with a newline

# Read JSON input from stdin
input=$(cat)

# Debug: Log the input to a file
echo "$(date): Hook triggered with input: $input" >> /tmp/claude-hook-debug.log

# Extract file path from the JSON input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_response.filePath')

# Check if file exists and is a regular file
if [[ -f "$file_path" ]]; then
    # Create a temporary file
    temp_file=$(mktemp)

    # Process the file:
    # 1. Remove trailing whitespace from all lines
    # 2. Ensure file ends with newline
    sed 's/[[:space:]]*$//' "$file_path" > "$temp_file"

    # Add newline at end if file is not empty and doesn't end with newline
    if [[ -s "$temp_file" ]] && [[ "$(tail -c1 "$temp_file" | wc -l)" -eq 0 ]]; then
        echo "" >> "$temp_file"
    fi

    # Replace original file with cleaned version
    mv "$temp_file" "$file_path"

    # Output success JSON for Claude Code
    echo '{"success": true, "message": "File cleaned: removed trailing whitespace and ensured newline at end"}'
else
    # File doesn't exist or is not a regular file
    echo '{"success": true, "message": "File does not exist or is not a regular file, skipping cleanup"}'
fi

exit 0
