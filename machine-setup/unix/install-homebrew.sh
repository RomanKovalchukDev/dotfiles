#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Homebrew not found."
  echo "  Installing Homebrew for you."

  # Install Homebrew (works on both macOS and Linux)
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  echo "  Adding Homebrew to PATH..."
  if test "$(uname)" = "Darwin"
  then
    # macOS: Homebrew is typically in /opt/homebrew (Apple Silicon) or /usr/local (Intel)
    if test -x "/opt/homebrew/bin/brew"; then
      echo "  Found Homebrew at /opt/homebrew/bin/brew"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif test -x "/usr/local/bin/brew"; then
      echo "  Found Homebrew at /usr/local/bin/brew"
      eval "$(/usr/local/bin/brew shellenv)"
    else
      echo "  Warning: Homebrew installed but binary not found in expected locations"
      echo "  You may need to add Homebrew to your PATH manually"
    fi
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
  then
    # Linux: Homebrew is typically in /home/linuxbrew
    if test -x "/home/linuxbrew/.linuxbrew/bin/brew"; then
      echo "  Found Homebrew at /home/linuxbrew/.linuxbrew/bin/brew"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  fi

  # Verify brew is now in PATH
  if test $(which brew 2>/dev/null); then
    echo "  Homebrew successfully added to PATH: $(which brew)"
  else
    echo "  Warning: brew command not found in PATH after installation"
  fi
else
  echo "  Homebrew already installed at $(which brew)"
fi

# Link keg-only formulas that we want in PATH
brew list | grep 'postgresql@' | xargs -I {} brew link {} --force 2>/dev/null

exit 0
