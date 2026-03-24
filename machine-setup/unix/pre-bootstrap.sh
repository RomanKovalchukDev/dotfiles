#!/usr/bin/env bash
#
# pre-bootstrap - Sets up SSH keys for GitHub access
#
# This should be run BEFORE cloning the dotfiles repository
# since the repo uses SSH URLs (git@github.com:...)

set -e

echo ""
echo "======================================"
echo "  Dotfiles Pre-Bootstrap Setup"
echo "  SSH Key Configuration"
echo "======================================"
echo ""

# Check if SSH key already exists
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
  echo "✓ SSH key already exists"

  if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
  elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
  fi

  echo ""
  echo "Your public key:"
  echo "----------------"
  cat "$SSH_KEY_PATH"
  echo "----------------"
  echo ""

  read -p "Do you need to add this key to GitHub? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Opening GitHub SSH settings..."
    echo "Add the key shown above to: https://github.com/settings/keys"

    # Copy to clipboard if pbcopy is available (macOS)
    if command -v pbcopy >/dev/null 2>&1; then
      cat "$SSH_KEY_PATH" | pbcopy
      echo "✓ Public key copied to clipboard"
    fi

    # Open GitHub settings if on macOS
    if [ "$(uname -s)" == "Darwin" ]; then
      open "https://github.com/settings/keys"
    fi

    echo ""
    read -p "Press ENTER after adding the key to GitHub..."
  fi
else
  echo "No SSH key found. Generating new SSH key..."
  echo ""

  # Get email for SSH key
  read -p "Enter your GitHub email: " git_email

  # Generate SSH key
  ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""

  echo ""
  echo "✓ SSH key generated"
  echo ""

  # Start ssh-agent and add key
  eval "$(ssh-agent -s)"

  # Add SSH key to ssh-agent
  ssh-add "$HOME/.ssh/id_ed25519"

  # Create/update SSH config for macOS keychain
  if [ "$(uname -s)" == "Darwin" ]; then
    if [ ! -f "$HOME/.ssh/config" ]; then
      touch "$HOME/.ssh/config"
    fi

    if ! grep -q "UseKeychain yes" "$HOME/.ssh/config"; then
      cat >> "$HOME/.ssh/config" << EOF

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
      echo "✓ Updated SSH config for macOS keychain"
    fi
  fi

  echo ""
  echo "======================================"
  echo "Your NEW public SSH key:"
  echo "======================================"
  cat "$HOME/.ssh/id_ed25519.pub"
  echo "======================================"
  echo ""

  # Copy to clipboard if pbcopy is available (macOS)
  if command -v pbcopy >/dev/null 2>&1; then
    cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
    echo "✓ Public key copied to clipboard"
  fi

  echo ""
  echo "Next steps:"
  echo "1. Add the SSH key to your GitHub account:"
  echo "   https://github.com/settings/keys"
  echo ""

  # Open GitHub settings if on macOS
  if [ "$(uname -s)" == "Darwin" ]; then
    open "https://github.com/settings/keys"
  fi

  read -p "2. Press ENTER after adding the key to GitHub..."
fi

echo ""
echo "Testing GitHub SSH connection..."
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && echo "✓ GitHub SSH connection successful!" || echo "⚠ GitHub SSH connection test completed (this is normal if you just added the key)"

echo ""
echo "======================================"
echo "SSH setup complete!"
echo "======================================"
echo ""
echo "You can now clone your dotfiles repository:"
echo "  git clone git@github.com:RomanKovalchukDev/dotfiles.git ~/.dotfiles"
echo "  cd ~/.dotfiles"
echo "  machine-setup/unix/bootstrap.sh"
echo ""

exit 0
