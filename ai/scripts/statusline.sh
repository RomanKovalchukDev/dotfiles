#!/bin/bash

# Read JSON input once
input=$(cat)

# Extract current directory
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Extract context percentage (remaining)
ctx_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // 0' | cut -d. -f1)

# Git information
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  # Get repo name (just the directory name)
  repo_name=$(basename "$cwd")

  # Color the context percentage based on remaining space
  if [ "$ctx_pct" -le 30 ]; then
    ctx_color='\033[01;31m' # red (low remaining)
  elif [ "$ctx_pct" -le 50 ]; then
    ctx_color='\033[01;33m' # yellow (medium remaining)
  else
    ctx_color='\033[01;32m' # green (high remaining)
  fi

  printf '\033[01;36m%s\033[00m | ctx: %b%s%%\033[00m' \
    "$repo_name" "$ctx_color" "$ctx_pct"
else
  printf '\033[01;36m%s\033[00m | ctx: %s%%' "$cwd" "$ctx_pct"
fi
