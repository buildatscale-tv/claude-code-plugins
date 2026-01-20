#!/bin/bash
# BuildAtScale Statusline - Enhanced Claude Code status display
#
# Features:
# - Context runway gauge (shows free context, not used)
# - Color-coded warnings: yellow (low) → red (critical)
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
SHOW_COST=false           # Show session cost (useful for API users, less relevant for subscriptions)
CONTEXT_DISPLAY="free"  # "free" = runway left, "used" = consumed
CONTEXT_DETAIL="minimal"     # "full" = progress bar + %, "minimal" = just % with warning colors

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
USED_PCT_RAW=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -z "$USED_PCT_RAW" ] || [ "$USED_PCT_RAW" = "null" ]; then
    USED_PCT="--"
    FREE_PCT="--"
else
    USED_PCT=$(printf "%.0f" "$USED_PCT_RAW")
    FREE_PCT=$((100 - USED_PCT))
    [ $FREE_PCT -lt 0 ] && FREE_PCT=0
fi

# Build context display
BAR_WIDTH=20
PCT_COLOR=""
BAR=""
BAR_PLAIN=""

# Determine which percentage to show
if [ "$CONTEXT_DISPLAY" = "free" ]; then
    DISPLAY_PCT=$FREE_PCT
else
    DISPLAY_PCT=$USED_PCT
fi

# Handle null/unavailable context data
if [ "$FREE_PCT" = "--" ]; then
    WARN_LEVEL="unknown"
    BAR=""
    BAR_PLAIN=""
    PCT_COLOR="$GRAY"
else
    # Determine warning level (based on free %, regardless of display mode)
    if [ $FREE_PCT -gt 25 ]; then
        WARN_LEVEL="ok"
    elif [ $FREE_PCT -gt 10 ]; then
        WARN_LEVEL="warning"
    else
        WARN_LEVEL="critical"
    fi

    # Build bar or set text color based on detail level
    if [ "$CONTEXT_DETAIL" = "full" ]; then
        FILLED=$((DISPLAY_PCT * BAR_WIDTH / 100))
        [ "$DISPLAY_PCT" -gt 0 ] && [ "$FILLED" -eq 0 ] && FILLED=1
        [ $FILLED -gt $BAR_WIDTH ] && FILLED=$BAR_WIDTH
        [ $FILLED -lt 0 ] && FILLED=0
        EMPTY=$((BAR_WIDTH - FILLED))

        # Warning colors apply to both modes (based on free %)
        case $WARN_LEVEL in
            ok) BAR_COLOR="$CTX_OK" ;;
            warning) BAR_COLOR="$CTX_WARNING" ;;
            critical) BAR_COLOR="$CTX_CRITICAL" ;;
        esac
        [ "$WARN_LEVEL" = "critical" ] && EMPTY_COLOR="$CTX_CRITICAL" || EMPTY_COLOR="$GRAY"
        BAR="${BAR_COLOR}$(printf '%*s' "$FILLED" '' | tr ' ' '█')${EMPTY_COLOR}$(printf '%*s' "$EMPTY" '' | tr ' ' '░')${RESET} "
        BAR_PLAIN="$(printf '%*s' "$FILLED" '' | tr ' ' '█')$(printf '%*s' "$EMPTY" '' | tr ' ' '░') "
    else
        # Minimal: no bar, colored percentage text (no color when OK)
        case $WARN_LEVEL in
            ok) PCT_COLOR="$GRAY" ;;
            warning) PCT_COLOR="$CTX_WARNING" ;;
            critical) PCT_COLOR="$CTX_CRITICAL" ;;
        esac
    fi
fi

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
RIGHT_PLAIN="+${LINES_ADDED}/-${LINES_REMOVED} | ${BAR_PLAIN}${DISPLAY_PCT}%${COST_SEGMENT_PLAIN} | ${MODEL}"
RIGHT="${MUTED_GREEN}+${LINES_ADDED}${GRAY}/${MUTED_RED}-${LINES_REMOVED}${GRAY} | ${BAR}${PCT_COLOR}${DISPLAY_PCT}%${RESET}${COST_SEGMENT} | ${MODEL}${RESET}"

# Right-align
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
PADDING=$((TERM_WIDTH - ${#LEFT_PLAIN} - ${#RIGHT_PLAIN}))
[ $PADDING -gt 0 ] && SPACES=$(printf '%*s' "$PADDING" '') || SPACES=" "
echo -e "${LEFT}${SPACES}${RIGHT}"
