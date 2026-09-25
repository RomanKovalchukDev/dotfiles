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

# Bootstrap runs this with stdout and stderr piped, so an interactive prompt here
# is invisible and looks like a hang. Follow bootstrap's documented policy instead:
# never overwrite, always back up with a timestamp.
link_with_backup() {
  src="$1"
  dst="$2"
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "  already linked: $dst"
      return 0
    fi
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    backup="$dst.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$dst" "$backup"
    echo "  backed up $dst to $backup"
  fi
  ln -s "$src" "$dst"
  echo "  linked $dst"
}

# Create Fish config directory
if [ ! -d "$HOME/.config/fish" ]; then
  mkdir -p "$HOME/.config/fish"
fi

# Symlink Fish config
echo "  Symlinking Fish configuration..."
link_with_backup "$DOTFILES_ROOT/config/unix/fish/config.fish" "$HOME/.config/fish/config.fish"

# Symlink fish_plugins (Fisher plugin list)
echo "  Symlinking Fish plugins list..."
link_with_backup "$DOTFILES_ROOT/config/unix/fish/fish_plugins.symlink" "$HOME/.config/fish/fish_plugins"

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
