#!/bin/bash
# AI configuration lives in the private dotclaude repository. This script only fetches and runs it.
set -e

DOTCLAUDE_DIR="${DOTCLAUDE_DIR:-$HOME/Documents/PersonalProjects/dotclaude}"
DOTCLAUDE_REPO="git@github.com:RomanKovalchukDev/dotclaude.git"

if ! command -v claude > /dev/null 2>&1; then
  echo "Claude Code CLI not found. Install it from https://code.claude.com and re run." >&2
  exit 1
fi

if [ ! -d "$DOTCLAUDE_DIR/.git" ]; then
  echo "Cloning dotclaude into $DOTCLAUDE_DIR"
  git clone "$DOTCLAUDE_REPO" "$DOTCLAUDE_DIR"
fi

exec "$DOTCLAUDE_DIR/install.sh"
