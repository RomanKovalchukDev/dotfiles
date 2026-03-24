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
  if test "$(uname)" = "Darwin"
  then
    # macOS: Homebrew is typically in /opt/homebrew or /usr/local
    if test -d "/opt/homebrew/bin"; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif test -d "/usr/local/bin/brew"; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
  then
    # Linux: Homebrew is typically in /home/linuxbrew
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
else
  echo "  Homebrew already installed at $(which brew)"
fi

# Link keg-only formulas that we want in PATH
brew list | grep 'postgresql@' | xargs -I {} brew link {} --force 2>/dev/null

exit 0
