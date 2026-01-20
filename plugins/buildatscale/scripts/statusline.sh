#!/bin/bash
# BuildAtScale Statusline - Enhanced Claude Code status display
#
# Features:
# - Context runway gauge (shows remaining context, not used)
# - Color-coded warnings: green (OK) → yellow (low) → red (critical)
# - Git branch display
# - Relative path when in subdirectories
# - Configurable cost display
#
# To enable, add to your ~/.claude/settings.json:
# {
#   "statusLine": {
#     "type": "command",
#     "command": "bash /path/to/statusline.sh"
#   }
# }

input=$(cat)

# Colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
GRAY='\033[90m'
MUTED_GREEN='\033[38;5;65m'
MUTED_RED='\033[38;5;131m'
RESET='\033[0m'
# Context bar colors (runway gauge)
CTX_OK='\033[38;5;23m'       # Very muted dark green - plenty of runway
CTX_WARNING='\033[38;5;136m' # Muted yellow/gold - getting low
CTX_CRITICAL='\033[38;5;131m' # Muted red - compaction imminent

# Configuration - Toggle items on/off
SHOW_COST=false        # Show session cost (useful for API users, less relevant for subscriptions)
CONTEXT_DISPLAY="remaining"  # "remaining" = runway gauge (default), "used" = classic fill-up

# Extract values
MODEL=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed')
# Cost (conditional)
COST_SEGMENT="" COST_SEGMENT_PLAIN=""
if [ "$SHOW_COST" = true ]; then
    COST=$(printf "%.2f" "$(echo "$input" | jq -r '.cost.total_cost_usd')")
    COST_SEGMENT=" | \$${COST}"
    COST_SEGMENT_PLAIN=" | \$${COST}"
fi
# Context usage (pre-calculated by Claude Code)
USED_PCT=$(printf "%.0f" "$(echo "$input" | jq -r '.context_window.used_percentage')")
REMAINING_PCT=$((100 - USED_PCT))
[ $REMAINING_PCT -lt 0 ] && REMAINING_PCT=0

# Build progress bar (20 chars wide, 5% per block)
BAR_WIDTH=20
if [ "$CONTEXT_DISPLAY" = "remaining" ]; then
    # Runway gauge: bar depletes as context is consumed
    DISPLAY_PCT=$REMAINING_PCT
    FILLED=$((REMAINING_PCT * BAR_WIDTH / 100))
    # Color based on remaining runway
    if [ $REMAINING_PCT -gt 25 ]; then
        BAR_COLOR="$CTX_OK"
    elif [ $REMAINING_PCT -gt 10 ]; then
        BAR_COLOR="$CTX_WARNING"
    else
        BAR_COLOR="$CTX_CRITICAL"
    fi
else
    # Classic: bar fills as context grows
    DISPLAY_PCT=$USED_PCT
    FILLED=$((USED_PCT * BAR_WIDTH / 100))
    [ "$USED_PCT" -gt 0 ] && [ "$FILLED" -eq 0 ] && FILLED=1
    BAR_COLOR="$GRAY"
fi
[ $FILLED -gt $BAR_WIDTH ] && FILLED=$BAR_WIDTH
[ $FILLED -lt 0 ] && FILLED=0
EMPTY=$((BAR_WIDTH - FILLED))
# At critical level, empty blocks also turn red
[ "$CONTEXT_DISPLAY" = "remaining" ] && [ $REMAINING_PCT -le 10 ] && EMPTY_COLOR="$CTX_CRITICAL" || EMPTY_COLOR="$GRAY"
BAR="${BAR_COLOR}$(printf '%*s' "$FILLED" '' | tr ' ' '█')${EMPTY_COLOR}$(printf '%*s' "$EMPTY" '' | tr ' ' '░')${RESET}"
BAR_PLAIN=$(printf '%*s' "$FILLED" '' | tr ' ' '█')$(printf '%*s' "$EMPTY" '' | tr ' ' '░')

# Git branch
GIT_BRANCH="" GIT_BRANCH_PLAIN=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH="[${GREEN}${BRANCH}${RESET}]" && GIT_BRANCH_PLAIN="[${BRANCH}]"
fi

# Build directory display (show relative path if in subdirectory)
# Use git root as project anchor if project_dir is unavailable or same as current
if [ -z "$PROJECT_DIR" ] || [ "$PROJECT_DIR" = "null" ] || [ "$PROJECT_DIR" = "$CURRENT_DIR" ]; then
    PROJECT_DIR=$(git -C "$CURRENT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$CURRENT_DIR")
fi
PROJECT_NAME="${PROJECT_DIR##*/}"
CURRENT_NAME="${CURRENT_DIR##*/}"
if [ "$CURRENT_DIR" = "$PROJECT_DIR" ]; then
    # At project root - just show name
    DIR_DISPLAY="$CURRENT_NAME"
elif [ "${CURRENT_DIR#$PROJECT_DIR/}" != "$CURRENT_DIR" ]; then
    # Inside project directory - show relative path
    REL_PATH="${CURRENT_DIR#$PROJECT_DIR/}"
    DEPTH=$(echo "$REL_PATH" | tr -cd '/' | wc -c)
    if [ "$DEPTH" -eq 0 ]; then
        # 1 level down: ./project/subdir
        DIR_DISPLAY="./${PROJECT_NAME}/${CURRENT_NAME}"
    else
        # 2+ levels down: ./project/../subdir
        DIR_DISPLAY="./${PROJECT_NAME}/../${CURRENT_NAME}"
    fi
else
    # Outside project (shouldn't happen normally) - just show name
    DIR_DISPLAY="$CURRENT_NAME"
fi

# Build output
LEFT="[${BLUE}${DIR_DISPLAY}${RESET}]${GIT_BRANCH}"
LEFT_PLAIN="[${DIR_DISPLAY}]${GIT_BRANCH_PLAIN}"
RIGHT_PLAIN="+${LINES_ADDED}/-${LINES_REMOVED} | ${BAR_PLAIN} ${DISPLAY_PCT}%${COST_SEGMENT_PLAIN} | ${MODEL}"
RIGHT="${MUTED_GREEN}+${LINES_ADDED}${GRAY}/${MUTED_RED}-${LINES_REMOVED}${GRAY} | ${BAR} ${DISPLAY_PCT}%${COST_SEGMENT} | ${MODEL}${RESET}"

# Right-align
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
PADDING=$((TERM_WIDTH - ${#LEFT_PLAIN} - ${#RIGHT_PLAIN}))
[ $PADDING -gt 0 ] && SPACES=$(printf '%*s' "$PADDING" '') || SPACES=" "
echo -e "${LEFT}${SPACES}${RIGHT}"
