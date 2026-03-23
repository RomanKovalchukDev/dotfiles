#!/bin/bash
#
# PreToolUse Hook
# Validates operations before execution
# Enforces dotfiles best practices

TOOL_NAME="$1"
FILE_PATH="$2"

# Only validate Write operations
if [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# Ensure we're in dotfiles directory
if [[ ! "$PWD" =~ dotfiles ]]; then
  exit 0
fi

# Extract relative path
REL_PATH="${FILE_PATH#$HOME/.dotfiles/}"
REL_PATH="${FILE_PATH#$PWD/}"

# Check if file follows topic-centric pattern
# Valid patterns:
#   - topic/*.zsh
#   - topic/*.fish
#   - topic/*.symlink
#   - topic/install.sh
#   - topic/bin/*
#   - topic/functions/*
#   - script/*
#   - claude/*

if [[ "$REL_PATH" =~ ^[a-z-]+/(.*\.(zsh|fish|symlink)|install\.sh|bin/.*|functions/.*)$ ]]; then
  exit 0
fi

if [[ "$REL_PATH" =~ ^(script|claude)/ ]]; then
  exit 0
fi

# Root-level files are OK
if [[ ! "$REL_PATH" =~ / ]]; then
  exit 0
fi

# If we got here, the file doesn't follow conventions
echo "⚠️  Warning: File doesn't follow topic-centric pattern"
echo "   File: $REL_PATH"
echo ""
echo "   Expected patterns:"
echo "     - topic/*.zsh or topic/*.fish (shell configs)"
echo "     - topic/*.symlink (files to symlink to ~)"
echo "     - topic/install.sh (install script)"
echo "     - topic/bin/* (executables)"
echo "     - topic/functions/* (shell functions)"
echo ""
echo "   Consider organizing by topic (git, system, docker, etc.)"

# Don't block, just warn
exit 0
