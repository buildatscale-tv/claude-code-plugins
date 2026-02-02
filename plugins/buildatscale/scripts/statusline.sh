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
# Flags:
#   --cost              Show session cost (off by default)
#   --display <free|used>  Context display mode (default: free)
#   --detail <full|minimal> Bar style vs just % (default: minimal)
#   --color-usage [warnings] Colorize context (all colors, or warnings only)
#   --usage-warning <pct>  Free % threshold for warning (default: 25)
#   --usage-critical <pct> Free % threshold for critical (default: 10)
#   --no-color          Disable all ANSI colors/formatting
#
# To enable, add to your ~/.claude/settings.json:
# {
#   "statusLine": {
#     "type": "command",
#     "command": "bash /path/to/statusline.sh --detail full --cost"
#   }
# }

# Defaults
SHOW_COST=false
CONTEXT_DISPLAY="free"
CONTEXT_DETAIL="minimal"
COLOR_USAGE="off"
USAGE_WARNING=25
USAGE_CRITICAL=10
NO_COLOR=false

# Parse flags (must happen before stdin is consumed)
while [ $# -gt 0 ]; do
    case "$1" in
        --cost)
            SHOW_COST=true
            shift
            ;;
        --display)
            CONTEXT_DISPLAY="$2"
            shift 2
            ;;
        --detail)
            CONTEXT_DETAIL="$2"
            shift 2
            ;;
        --color-usage)
            if [ -n "$2" ] && [ "$2" = "warnings" ]; then
                COLOR_USAGE="warnings"
                shift 2
            else
                COLOR_USAGE="all"
                shift
            fi
            ;;
        --usage-warning)
            USAGE_WARNING="$2"
            shift 2
            ;;
        --usage-critical)
            USAGE_CRITICAL="$2"
            shift 2
            ;;
        --no-color)
            NO_COLOR=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

input=$(cat)

# Colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
GRAY='\033[90m'
MUTED_GREEN='\033[38;5;65m'
MUTED_RED='\033[38;5;131m'
RESET='\033[0m'
# Context bar colors (runway gauge)
CTX_OK='\033[38;5;23m'       # Very muted dark green - bar fill
CTX_OK_TEXT='\033[38;5;65m' # Lighter muted green - percentage text
CTX_WARNING='\033[38;5;136m' # Muted yellow/gold - getting low
CTX_CRITICAL='\033[38;5;131m' # Muted red - compaction needed soon

# --no-color: blank out all color variables
if [ "$NO_COLOR" = true ]; then
    BLUE="" GREEN="" GRAY="" MUTED_GREEN="" MUTED_RED="" RESET=""
    CTX_OK="" CTX_OK_TEXT="" CTX_WARNING="" CTX_CRITICAL=""
fi

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
FREE_PCT_RAW=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -z "$USED_PCT_RAW" ] || [ "$USED_PCT_RAW" = "null" ]; then
    USED_PCT="--"
    FREE_PCT="--"
else
    USED_PCT=$(printf "%.0f" "$USED_PCT_RAW")
    if [ -n "$FREE_PCT_RAW" ] && [ "$FREE_PCT_RAW" != "null" ]; then
        FREE_PCT=$(printf "%.0f" "$FREE_PCT_RAW")
    else
        FREE_PCT=$((100 - USED_PCT))
    fi
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
    if [ $FREE_PCT -gt $USAGE_WARNING ]; then
        WARN_LEVEL="ok"
    elif [ $FREE_PCT -gt $USAGE_CRITICAL ]; then
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

        # Bar colors based on --color-usage mode
        if [ "$COLOR_USAGE" = "all" ]; then
            case $WARN_LEVEL in
                ok) BAR_COLOR="$CTX_OK" ;;
                warning) BAR_COLOR="$CTX_WARNING" ;;
                critical) BAR_COLOR="$CTX_CRITICAL" ;;
            esac
            [ "$WARN_LEVEL" = "critical" ] && EMPTY_COLOR="$CTX_CRITICAL" || EMPTY_COLOR="$GRAY"
        elif [ "$COLOR_USAGE" = "warnings" ]; then
            case $WARN_LEVEL in
                ok) BAR_COLOR="$GRAY" ;;
                warning) BAR_COLOR="$CTX_WARNING" ;;
                critical) BAR_COLOR="$CTX_CRITICAL" ;;
            esac
            [ "$WARN_LEVEL" = "critical" ] && EMPTY_COLOR="$CTX_CRITICAL" || EMPTY_COLOR="$GRAY"
        else
            BAR_COLOR="$GRAY"
            EMPTY_COLOR="$GRAY"
        fi
        BAR="${BAR_COLOR}$(printf '%*s' "$FILLED" '' | tr ' ' '█')${EMPTY_COLOR}$(printf '%*s' "$EMPTY" '' | tr ' ' '░')${RESET} "
        BAR_PLAIN="$(printf '%*s' "$FILLED" '' | tr ' ' '█')$(printf '%*s' "$EMPTY" '' | tr ' ' '░') "
    fi

    # Color the percentage text based on --color-usage mode
    if [ "$COLOR_USAGE" = "all" ]; then
        case $WARN_LEVEL in
            ok) PCT_COLOR="$CTX_OK_TEXT" ;;
            warning) PCT_COLOR="$CTX_WARNING" ;;
            critical) PCT_COLOR="$CTX_CRITICAL" ;;
        esac
    elif [ "$COLOR_USAGE" = "warnings" ]; then
        case $WARN_LEVEL in
            ok) PCT_COLOR="$GRAY" ;;
            warning) PCT_COLOR="$CTX_WARNING" ;;
            critical) PCT_COLOR="$CTX_CRITICAL" ;;
        esac
    else
        PCT_COLOR="$GRAY"
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
