#!/bin/bash
#
# SessionStart Hook
# Runs when a new Claude Code session starts
# Detects active shell and provides context

# Detect current shell
if [ -n "$FISH_VERSION" ]; then
  ACTIVE_SHELL="fish"
elif [ -n "$ZSH_VERSION" ]; then
  ACTIVE_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
  ACTIVE_SHELL="bash"
else
  ACTIVE_SHELL="unknown"
fi

# Check if shell configs exist
FISH_CONFIG="$HOME/.config/fish/config.fish"
ZSH_CONFIG="$HOME/.zshrc"

echo "Active shell: $ACTIVE_SHELL"
echo ""
echo "Shell configs:"
[ -L "$FISH_CONFIG" ] && echo "  ✓ Fish config linked" || echo "  ✗ Fish config not linked"
[ -L "$ZSH_CONFIG" ] && echo "  ✓ ZSH config linked" || echo "  ✗ ZSH config not linked"
echo ""

# Count active skills
if [ -d "$HOME/.claude/skills" ]; then
  SKILL_COUNT=$(ls -1 "$HOME/.claude/skills" | wc -l | tr -d ' ')
  echo "Claude skills active: $SKILL_COUNT"
else
  echo "Claude skills: not configured"
fi
