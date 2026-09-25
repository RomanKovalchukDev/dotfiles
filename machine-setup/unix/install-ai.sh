#!/bin/bash
# AI configuration lives in the private dotclaude repository. This script only fetches and runs it.
set -e

DOTCLAUDE_DIR="${DOTCLAUDE_DIR:-$HOME/Documents/PersonalProjects/dotclaude}"
DOTCLAUDE_REPO="git@github.com:RomanKovalchukDev/dotclaude.git"

# The claude-code cask can have been installed moments ago by a sibling script
# whose brew shellenv never reached this process, so look for Homebrew first.
if ! command -v brew > /dev/null 2>&1; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -x "$candidate" ] && eval "$("$candidate" shellenv)" && break
  done
fi

if ! command -v claude > /dev/null 2>&1; then
  echo "Claude Code CLI not found. It comes from the claude-code cask in machine-setup/unix/Brewfile." >&2
  echo "Run: brew bundle --file machine-setup/unix/Brewfile" >&2
  exit 1
fi

if [ ! -d "$DOTCLAUDE_DIR/.git" ]; then
  echo "Cloning dotclaude into $DOTCLAUDE_DIR"
  git clone "$DOTCLAUDE_REPO" "$DOTCLAUDE_DIR"
fi

exec "$DOTCLAUDE_DIR/install.sh"
