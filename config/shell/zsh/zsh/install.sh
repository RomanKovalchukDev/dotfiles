#!/bin/sh
#
# ZSH shell configuration
# The zshrc symlink is created by script/bootstrap automatically
# This script just confirms if you want to use ZSH

# Check if running interactively
if [ -t 0 ]; then
  # Ask user if they want to set up ZSH (since fish is default)
  printf "  Do you want to set up ZSH shell configuration? [y/N] "
  read -r response

  case "$response" in
    [yY][eE][sS]|[yY])
      echo "  ZSH configuration is already symlinked by bootstrap"
      echo "  To use ZSH, run: chsh -s \$(which zsh)"
      ;;
    *)
      echo "  Skipping ZSH configuration (Fish is default)"
      # Optionally remove the zshrc symlink if user doesn't want it
      if [ -L "$HOME/.zshrc" ]; then
        printf "  Remove ~/.zshrc symlink? [y/N] "
        read -r remove_response
        case "$remove_response" in
          [yY][eE][sS]|[yY])
            rm "$HOME/.zshrc"
            echo "  Removed ~/.zshrc symlink"
            ;;
          *)
            echo "  Keeping ~/.zshrc symlink (inactive unless you use zsh)"
            ;;
        esac
      fi
      exit 0
      ;;
  esac
fi
