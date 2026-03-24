#!/usr/bin/env bash
#
# Run all dotfiles installers.

# Don't exit on error - we want to try everything even if something fails
set +e

cd "$(dirname $0)"/../..

# Install Homebrew (works on both macOS and Linux)
echo "› Installing Homebrew"
sh machine-setup/unix/install-homebrew.sh

# Add Homebrew to PATH for this session
# This is needed because install-homebrew.sh runs in a subshell
if ! command -v brew >/dev/null 2>&1; then
  echo "› Configuring Homebrew PATH"
  if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: Homebrew is in /opt/homebrew (Apple Silicon) or /usr/local (Intel)
    if [ -x "/opt/homebrew/bin/brew" ]; then
      echo "  Found Homebrew at /opt/homebrew/bin/brew"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
      echo "  Found Homebrew at /usr/local/bin/brew"
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    # Linux: Homebrew is in /home/linuxbrew
    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
      echo "  Found Homebrew at /home/linuxbrew/.linuxbrew/bin/brew"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  fi

  # Verify brew is now available
  if command -v brew >/dev/null 2>&1; then
    echo "  Homebrew in PATH: $(which brew)"
  else
    echo "  WARNING: Cannot find brew after installation"
    echo "  Skipping brew bundle..."
    exit 1
  fi
fi

# Install packages via Homebrew
echo "› brew bundle"
if ! brew bundle --file=machine-setup/unix/Brewfile; then
  echo "  WARNING: Some Homebrew packages failed to install"
  echo "  You may need to run 'brew bundle --file=machine-setup/unix/Brewfile' manually"
fi

# Setup Fish shell (Fisher + Bass)
echo "› Setting up Fish"
if ! sh machine-setup/unix/install-fish.sh; then
  echo "  WARNING: Fish setup failed"
fi

# Set Ghostty as default terminal (macOS only)
if [ "$(uname -s)" == "Darwin" ]
then
  echo "› Setting Ghostty as default terminal"
  if ! sh machine-setup/mac/set-default-terminal.sh; then
    echo "  WARNING: Failed to set Ghostty as default terminal"
  fi
fi

# Install ZSH (optional, interactive)
echo "› Setting up ZSH"
if ! sh machine-setup/unix/install-zsh.sh; then
  echo "  WARNING: ZSH setup failed or was skipped"
fi

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
