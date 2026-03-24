#!/bin/sh
#
# Fish shell setup
# Installs Fisher (plugin manager) and Bass (bash compatibility)
#
# Note: Fish itself is installed via Brewfile

# Check if Fish is installed
if ! command -v fish >/dev/null 2>&1; then
  echo "  Fish is not installed. It should be installed via brew bundle."
  exit 1
fi

echo "  Setting up Fish shell..."

# Install Fisher (Fish plugin manager)
echo "  Installing Fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install Bass (run bash utilities in Fish)
echo "  Installing Bass plugin..."
fish -c "fisher install edc/bass"

echo "  Fish setup complete!"
echo "  To set Fish as default shell, run: chsh -s \$(which fish)"

exit 0
