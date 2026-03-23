#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

cd "$(dirname $0)"/../..

# Install Homebrew first (prerequisite for everything)
echo "› Installing Homebrew"
sh machine-setup/mac/install-homebrew.sh

# Install packages via Homebrew
echo "› brew bundle"
brew bundle --file=machine-setup/mac/Brewfile

# Setup Fish shell (Fisher + Bass)
echo "› Setting up Fish"
sh machine-setup/mac/install-fish.sh

# Install ZSH (optional, interactive)
echo "› Setting up ZSH"
sh machine-setup/mac/install-zsh.sh

# Find and run any other installers in config directory
find config/mac -name install.sh | while read installer ; do
  echo "› Running ${installer}"
  sh -c "${installer}"
done
