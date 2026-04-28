#!/bin/sh
input=$(cat)

# Current working directory from Claude context
cwd=$(echo "$input" | jq -r '.cwd // empty')

# Git info (skip locks to avoid contention)
git_repo=""
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_repo=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Context window usage
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limit: 5-hour session usage
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Rate limit: 7-day weekly usage
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

parts=""

# Git section: repo  branch
if [ -n "$git_repo" ] && [ -n "$git_branch" ]; then
  parts=" ${git_repo}  ${git_branch}"
elif [ -n "$git_repo" ]; then
  parts=" ${git_repo}"
fi

# Separator between git and usage stats
usage=""

if [ -n "$ctx_used" ]; then
  ctx_fmt=$(printf "%.0f" "$ctx_used")
  usage="ctx:${ctx_fmt}%"
fi

five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

if [ -n "$five_pct" ]; then
  five_fmt=$(printf "%.0f" "$five_pct")
  five_label="5h:${five_fmt}%"
  if [ -n "$five_resets" ]; then
    now=$(date +%s)
    remaining=$((five_resets - now))
    if [ "$remaining" -gt 0 ]; then
      hrs=$((remaining / 3600))
      mins=$(( (remaining % 3600) / 60 ))
      if [ "$hrs" -gt 0 ]; then
        five_label="${five_label} (${hrs}h${mins}m)"
      else
        five_label="${five_label} (${mins}m)"
      fi
    fi
  fi
  if [ -n "$usage" ]; then
    usage="${usage}  ${five_label}"
  else
    usage="$five_label"
  fi
fi

if [ -n "$week_pct" ]; then
  week_fmt=$(printf "%.0f" "$week_pct")
  if [ -n "$usage" ]; then
    usage="${usage}  7d:${week_fmt}%"
  else
    usage="7d:${week_fmt}%"
  fi
fi

if [ -n "$usage" ]; then
  if [ -n "$parts" ]; then
    parts="${parts}  ·  ${usage}"
  else
    parts="$usage"
  fi
fi

if [ -n "$parts" ]; then
  printf "%s" "$parts"
fi
