#!/bin/sh
#
# Fish shell configuration
# Creates symlink for fish config file (default shell)

# Check if fish is installed
if ! command -v fish >/dev/null 2>&1; then
  echo "  Fish shell is not installed. Skipping fish configuration."
  echo "  Run 'brew bundle' to install fish."
  exit 0
fi

# Create fish config directory if it doesn't exist
mkdir -p ~/.config/fish

# Symlink the main config file
ln -sf $HOME/.dotfiles/fish/config.fish ~/.config/fish/config.fish

echo "  Fish configuration symlinked (default shell)"
