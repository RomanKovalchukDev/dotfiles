#!/bin/sh
#
# Fish shell setup
# Installs Fisher (plugin manager), Bass (bash compatibility), and symlinks config
#
# Note: Fish itself is installed via Brewfile

# Check if Fish is installed
if ! command -v fish >/dev/null 2>&1; then
  echo "  Fish is not installed. It should be installed via brew bundle."
  exit 1
fi

echo "  Setting up Fish shell..."

# Get absolute path to dotfiles
DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Create Fish config directory
if [ ! -d "$HOME/.config/fish" ]; then
  mkdir -p "$HOME/.config/fish"
fi

# Symlink Fish config
echo "  Symlinking Fish configuration..."
if [ -L "$HOME/.config/fish/config.fish" ] || [ -f "$HOME/.config/fish/config.fish" ]; then
  echo "  Fish config already exists at ~/.config/fish/config.fish"
  read -p "  Overwrite? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$HOME/.config/fish/config.fish"
    ln -s "$DOTFILES_ROOT/config/unix/fish/config.fish" "$HOME/.config/fish/config.fish"
    echo "  Fish config symlinked"
  else
    echo "  Skipping Fish config symlink"
  fi
else
  ln -s "$DOTFILES_ROOT/config/unix/fish/config.fish" "$HOME/.config/fish/config.fish"
  echo "  Fish config symlinked"
fi

# Symlink fish_plugins (Fisher plugin list)
echo "  Symlinking Fish plugins list..."
if [ -L "$HOME/.config/fish/fish_plugins" ] || [ -f "$HOME/.config/fish/fish_plugins" ]; then
  echo "  fish_plugins already exists at ~/.config/fish/fish_plugins"
  read -p "  Overwrite? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$HOME/.config/fish/fish_plugins"
    ln -s "$DOTFILES_ROOT/config/unix/fish/fish_plugins.symlink" "$HOME/.config/fish/fish_plugins"
    echo "  fish_plugins symlinked"
  else
    echo "  Skipping fish_plugins symlink"
  fi
else
  ln -s "$DOTFILES_ROOT/config/unix/fish/fish_plugins.symlink" "$HOME/.config/fish/fish_plugins"
  echo "  fish_plugins symlinked"
fi

# Install Fisher (Fish plugin manager)
echo "  Installing Fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install all plugins from fish_plugins file (Tide, Z, etc.)
echo "  Installing Fish plugins from fish_plugins..."
fish -c "fisher update"

# Configure Tide theme
echo "  Configuring Tide prompt theme..."
fish "$DOTFILES_ROOT/config/unix/fish/configure-tide.fish"

# Add Fish to allowed shells if not already there
FISH_PATH=$(which fish)
if ! grep -q "$FISH_PATH" /etc/shells; then
  echo "  Adding Fish to /etc/shells..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

# Set Fish as default shell
echo "  Setting Fish as default shell..."
chsh -s "$FISH_PATH"

echo "  Fish setup complete!"
echo "  Fish is now your default shell (restart terminal to apply)"

exit 0
