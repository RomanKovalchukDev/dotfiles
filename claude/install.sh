#!/bin/sh
#
# Claude Code configuration
# Sets up skills, agents, and settings for Claude Code CLI

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

set -e

CLAUDE_DIR="$HOME/.claude"
PRIVATE_REPO_URL=""  # Set this to your private skills repo URL if you have one
PRIVATE_DOTFILES_DIR="$HOME/.dotfiles-private"

# Colors for output
info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit 1
}

# Create Claude directories
info "Setting up Claude Code directories"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/agents"
success "Claude directories created"

# Symlink settings.json
info "Linking Claude settings"
if [ -f "$DOTFILES_ROOT/claude/settings.json" ]; then
  ln -sf "$DOTFILES_ROOT/claude/settings.json" "$CLAUDE_DIR/settings.json"
  success "Settings linked"
fi

# Symlink all skills (directory-based)
info "Linking public skills from dotfiles"
skill_count=0
if [ -d "$DOTFILES_ROOT/claude/skills" ]; then
  for skill_dir in "$DOTFILES_ROOT/claude/skills"/*; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      # Remove existing symlink if it exists
      rm -f "$CLAUDE_DIR/skills/$skill_name"
      # Create new symlink
      ln -sf "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
      skill_count=$((skill_count + 1))
    fi
  done
  success "Linked $skill_count public skills"
else
  info "No public skills directory found"
fi

# Symlink agents
info "Linking agents"
agent_count=0
if [ -d "$DOTFILES_ROOT/claude/agents" ]; then
  for agent_file in "$DOTFILES_ROOT/claude/agents"/*.md; do
    if [ -f "$agent_file" ]; then
      agent_name=$(basename "$agent_file")
      ln -sf "$agent_file" "$CLAUDE_DIR/agents/$agent_name"
      agent_count=$((agent_count + 1))
    fi
  done
  success "Linked $agent_count agents"
else
  info "No agents directory found"
fi

# Symlink statusline script
if [ -f "$DOTFILES_ROOT/claude/statusline.sh" ]; then
  ln -sf "$DOTFILES_ROOT/claude/statusline.sh" "$CLAUDE_DIR/statusline.sh"
  chmod +x "$CLAUDE_DIR/statusline.sh"
  success "Statusline script linked"
fi

# Handle private skills (if configured)
if [ -n "$PRIVATE_REPO_URL" ]; then
  info "Checking for private skills repository"

  if [ ! -d "$PRIVATE_DOTFILES_DIR" ]; then
    printf "  Private dotfiles not found. Clone it? [y/N] "
    read -r response

    case "$response" in
      [yY][eE][sS]|[yY])
        git clone "$PRIVATE_REPO_URL" "$PRIVATE_DOTFILES_DIR"
        success "Private dotfiles cloned"
        ;;
      *)
        info "Skipping private skills"
        ;;
    esac
  fi

  if [ -d "$PRIVATE_DOTFILES_DIR/claude/skills" ]; then
    private_skill_count=0
    for skill_dir in "$PRIVATE_DOTFILES_DIR/claude/skills"/*; do
      if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        rm -f "$CLAUDE_DIR/skills/$skill_name"
        ln -sf "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
        private_skill_count=$((private_skill_count + 1))
      fi
    done
    success "Linked $private_skill_count private skills"
  fi
fi

echo ""
success "Claude Code configuration complete!"
echo ""
echo "  Skills active: $(ls -1 "$CLAUDE_DIR/skills" | wc -l | tr -d ' ')"
echo "  Agents active: $(ls -1 "$CLAUDE_DIR/agents" 2>/dev/null | wc -l | tr -d ' ')"
echo ""
