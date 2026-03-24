#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

cd "$(dirname $0)"/../..

# Install Homebrew (works on both macOS and Linux)
echo "› Installing Homebrew"
sh machine-setup/unix/install-homebrew.sh

# Install packages via Homebrew
echo "› brew bundle"
brew bundle --file=machine-setup/unix/Brewfile

# Setup Fish shell (Fisher + Bass)
echo "› Setting up Fish"
sh machine-setup/unix/install-fish.sh

# Set Ghostty as default terminal (macOS only)
if [ "$(uname -s)" == "Darwin" ]
then
  echo "› Setting Ghostty as default terminal"
  sh machine-setup/mac/set-default-terminal.sh
fi

# Install ZSH (optional, interactive)
echo "› Setting up ZSH"
sh machine-setup/unix/install-zsh.sh

# Find and run any other installers in config directory
if [ "$(uname -s)" == "Darwin" ]
then
  # macOS: search both mac and unix configs
  find config/mac config/unix -name install.sh 2>/dev/null | while read installer ; do
    echo "› Running ${installer}"
    sh -c "${installer}"
  done
else
  # Linux: search only unix configs
  find config/unix -name install.sh 2>/dev/null | while read installer ; do
    echo "› Running ${installer}"
    sh -c "${installer}"
  done
fi
