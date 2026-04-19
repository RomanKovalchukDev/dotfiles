#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Claude Code User Config Setup ==="
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/mcp-configs"

# Config files
ln -sf "$DOTFILES_DIR/.claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ln -sf "$DOTFILES_DIR/.claude/settings.json" "$CLAUDE_DIR/settings.json"
ln -sf "$DOTFILES_DIR/scripts/statusline.sh" "$CLAUDE_DIR/statusline.sh"
ln -sf "$DOTFILES_DIR/.claude/mcp-configs/mcp-servers.json" "$CLAUDE_DIR/mcp-configs/mcp-servers.json"

# Nerd skills
echo "Linking nerd skills..."
for skill in "$DOTFILES_DIR/.claude/skills"/nerd-*; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    ln -sf "$skill" "$CLAUDE_DIR/skills/$name"
    echo "  $name"
done

echo ""
echo "Done. User config symlinked."
echo ""
echo "To install ECC (rules, agents, ECC skills):"
echo "  cd ~/Documents/PersonalProjects/setup/everything-claude-code"
echo "  ./install.sh"
echo ""
echo "To install marketplace plugins:"
echo "  claude install everything-claude-code"
echo "  claude install swift-lsp"
