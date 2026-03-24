#!/usr/bin/env bash
#
# bootstrap installs things.

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

set -e

# Parse command line flags
RUN_SET_DEFAULTS=false
RUN_SET_HOSTNAME=false
DRY_RUN=false
AUTO_MODE="backup"  # Default to backup mode instead of prompting
SHELL_CHOICE=""  # User's shell choice (zsh, fish, or skip)

usage() {
  echo "Usage: bootstrap.sh [options]"
  echo ""
  echo "Options:"
  echo "  -a, --all             Run all optional setup (defaults + hostname)"
  echo "  -d, --set-defaults    Run macOS set-defaults.sh (sets system preferences)"
  echo "  -n, --set-hostname    Run macOS set-hostname.sh (sets computer hostname)"
  echo "  --shell <zsh|fish|skip>  Choose shell to install (prompts if not specified)"
  echo "  -i, --interactive     Prompt for each file conflict (skip or backup)"
  echo "  -v, --verbose         Enable verbose logging"
  echo "  --dry-run             Preview what would be done without making changes"
  echo "  -h, --help            Show this help message"
  echo ""
  echo "By default, existing files are backed up automatically with timestamps."
  echo "Overwriting is not supported - all existing files are preserved."
  echo ""
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--all)
      RUN_SET_DEFAULTS=true
      RUN_SET_HOSTNAME=true
      shift
      ;;
    -d|--set-defaults)
      RUN_SET_DEFAULTS=true
      shift
      ;;
    -n|--set-hostname)
      RUN_SET_HOSTNAME=true
      shift
      ;;
    --shell)
      SHELL_CHOICE="$2"
      if [ "$SHELL_CHOICE" != "zsh" ] && [ "$SHELL_CHOICE" != "fish" ] && [ "$SHELL_CHOICE" != "skip" ]; then
        echo "Invalid shell choice: $SHELL_CHOICE"
        echo "Must be 'zsh', 'fish', or 'skip'"
        exit 1
      fi
      shift 2
      ;;
    -i|--interactive)
      AUTO_MODE=""
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

echo ''

if [ "$DRY_RUN" == "true" ]; then
  echo "========================================="
  echo "  DRY RUN MODE - No changes will be made"
  echo "========================================="
  echo ''
fi

# Initialize git submodules
if [ -f .gitmodules ]; then
  if [ "$DRY_RUN" == "true" ]; then
    info "Would initialize git submodules"
  else
    echo "Initializing git submodules..."
    git submodule update --init --recursive
  fi
fi

echo ''

info () {
  if [ "$DRY_RUN" == "true" ]; then
    printf "\r  [ \033[00;35mDRY\033[0m ] $1\n"
  else
    printf "\r  [ \033[00;34m..\033[0m ] $1\n"
  fi
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  if [ "$DRY_RUN" == "true" ]; then
    printf "\r\033[2K  [ \033[00;35mDRY\033[0m ] would: $1\n"
  else
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
  fi
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

warning () {
  printf "\r\033[2K  [\033[0;33mWARN\033[0m] $1\n"
}

debug () {
  if [ "$VERBOSE" == "true" ]; then
    printf "\r  [ \033[00;36mDEBUG\033[0m ] $1\n"
  fi
}

validate_config_dir () {
  debug "Checking ~/.config status..."

  # Check for broken symlinks (they exist as links but -e returns false)
  if [ -L "$HOME/.config" ] && [ ! -e "$HOME/.config" ]; then
    debug "~/.config is a broken symlink pointing to: $(readlink $HOME/.config)"
    local backup_name="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
    warning "~/.config is a broken symlink, backing up to $backup_name..."
    mv "$HOME/.config" "$backup_name"
  fi

  if [ -e "$HOME/.config" ]; then
    if [ -L "$HOME/.config" ]; then
      debug "~/.config exists as a symlink: $(readlink $HOME/.config)"
      if [ ! -d "$HOME/.config" ]; then
        fail "~/.config is a symlink but does not point to a directory. Please fix this:\n  rm ~/.config && mkdir ~/.config"
      fi
    elif [ -f "$HOME/.config" ]; then
      debug "~/.config exists as a regular file"
      fail "~/.config exists but is a file, not a directory. Please fix this:\n  mv ~/.config ~/.config.backup && mkdir ~/.config"
    elif [ -d "$HOME/.config" ]; then
      debug "~/.config exists as a directory (OK)"
    else
      debug "~/.config exists but is neither file nor directory"
    fi
  else
    debug "~/.config does not exist, creating it..."
    if mkdir -p "$HOME/.config"; then
      debug "Successfully created ~/.config directory"
    else
      fail "Failed to create ~/.config directory"
    fi
  fi

  # Final check: ensure it's a directory
  if [ ! -d "$HOME/.config" ]; then
    fail "~/.config is not a directory after validation"
  fi
}

setup_gitconfig () {
  if ! [ -f config/unix/git/gitconfig.local.symlink ] && ! [ -f "$HOME/.gitconfig" ]
  then
    info 'setup gitconfig'

    if [ "$DRY_RUN" == "true" ]; then
      success 'create gitconfig from template'
      return
    fi

    git_credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      git_credential='osxkeychain'
    fi

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" config/unix/git/gitconfig.local.symlink.example > config/unix/git/gitconfig.local.symlink

    success 'gitconfig'
  fi
}


link_file () {
  local src=$1 dst=$2

  local backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then
    # Check if already correctly linked
    local currentSrc="$(readlink $dst 2>/dev/null || echo '')"

    if [ "$currentSrc" == "$src" ]
    then
      skip=true;
    else
      # Handle AUTO_MODE (global setting)
      if [ "$AUTO_MODE" == "backup" ]; then
        backup=true
      elif [ -z "$AUTO_MODE" ] && [ "$backup_all" != "true" ] && [ "$skip_all" != "true" ]
      then
        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [b]ackup, [B]ackup all (recommended)?"
        read -n 1 action

        case "$action" in
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi

      backup=${backup:-$backup_all}
      skip=${skip:-$skip_all}

      if [ "$backup" == "true" ]
      then
        if [ "$DRY_RUN" == "true" ]; then
          success "move $dst to ${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        else
          local backup_name="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
          mv "$dst" "$backup_name"
          success "moved $dst to $backup_name"
        fi
      fi

      if [ "$skip" == "true" ]
      then
        success "skipped $src"
      fi
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    if [ "$DRY_RUN" == "true" ]; then
      success "link $1 to $2"
    else
      ln -s "$1" "$2"
      success "linked $1 to $2"
    fi
  fi
}

install_dotfiles () {
  info 'installing dotfiles'

  # Don't set local variables if AUTO_MODE is set globally
  if [ -z "$AUTO_MODE" ]; then
    local overwrite_all=false backup_all=false skip_all=false
  fi

  for src in $(find -H "$DOTFILES_ROOT/config" -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

setup_claude_code () {
  info 'setting up Claude Code configuration'

  # Create ~/.claude directory
  debug "Creating ~/.claude directory..."
  if [ "$DRY_RUN" == "true" ]; then
    success "create directory $HOME/.claude"
  else
    if mkdir -p "$HOME/.claude" 2>&1; then
      debug "Successfully created ~/.claude directory"
    else
      fail "Failed to create ~/.claude directory"
    fi
  fi

  # Don't set local variables if AUTO_MODE is set globally
  if [ -z "$AUTO_MODE" ]; then
    local overwrite_all=false backup_all=false skip_all=false
  fi

  # Symlink commands
  link_file "$DOTFILES_ROOT/ai/everything-claude-code/commands" "$HOME/.claude/commands"

  # Symlink agents
  link_file "$DOTFILES_ROOT/ai/everything-claude-code/agents" "$HOME/.claude/agents"

  # Symlink skills
  link_file "$DOTFILES_ROOT/ai/everything-claude-code/.claude/skills" "$HOME/.claude/skills"

  # Symlink other .claude subdirectories
  for dir in "$DOTFILES_ROOT/ai/everything-claude-code/.claude"/*; do
    if [ -d "$dir" ]; then
      dirname=$(basename "$dir")
      # Skip skills (already handled), commands (at root level), and agents (at root level)
      if [ "$dirname" != "skills" ] && [ "$dirname" != "commands" ] && [ "$dirname" != "agents" ]; then
        link_file "$dir" "$HOME/.claude/$dirname"
      fi
    fi
  done

  success 'Claude Code configuration linked'
}

setup_ghostty () {
  info 'setting up Ghostty configuration'

  # Validate ~/.config exists and is a directory
  validate_config_dir

  # Create Ghostty config directory
  debug "Creating ~/.config/ghostty directory..."
  debug "HOME is: $HOME"
  debug "Current directory is: $(pwd)"

  if [ "$DRY_RUN" == "true" ]; then
    success "create directory $HOME/.config/ghostty"
  else
    if mkdir -p "$HOME/.config/ghostty" 2>&1; then
      debug "Successfully created ~/.config/ghostty directory"
    else
      fail "Failed to create ~/.config/ghostty directory. Error: $?"
    fi
  fi

  # Don't set local variables if AUTO_MODE is set globally
  if [ -z "$AUTO_MODE" ]; then
    local overwrite_all=false backup_all=false skip_all=false
  fi

  # Symlink Ghostty config
  debug "Linking ghostty config from $DOTFILES_ROOT/config/unix/ghostty/config to $HOME/.config/ghostty/config"
  link_file "$DOTFILES_ROOT/config/unix/ghostty/config" "$HOME/.config/ghostty/config"

  success 'Ghostty configuration linked'
}

setup_dotfiles_symlink () {
  info 'setting up dotfiles symlink'

  # Create ~/.dotfiles symlink pointing to the actual dotfiles location
  # This allows Fish and other tools to find dotfiles at a consistent location
  # Don't set local variables if AUTO_MODE is set globally
  if [ -z "$AUTO_MODE" ]; then
    local overwrite_all=false backup_all=false skip_all=false
  fi
  link_file "$DOTFILES_ROOT" "$HOME/.dotfiles"

  success 'dotfiles symlink created'
}

# Prompt for shell choice if not specified
if [ -z "$SHELL_CHOICE" ] && [ "$DRY_RUN" != "true" ]; then
  echo ""
  echo "Which shell would you like to install and configure?"
  echo "  1) Fish (modern, user-friendly shell with great defaults)"
  echo "  2) ZSH (powerful, customizable shell)"
  echo "  3) Skip shell installation"
  echo ""
  read -p "Enter choice [1-3]: " choice
  case $choice in
    1)
      SHELL_CHOICE="fish"
      ;;
    2)
      SHELL_CHOICE="zsh"
      ;;
    3)
      SHELL_CHOICE="skip"
      ;;
    *)
      echo "Invalid choice. Skipping shell installation."
      SHELL_CHOICE="skip"
      ;;
  esac
  echo ""
fi

setup_gitconfig
setup_dotfiles_symlink
install_dotfiles
setup_claude_code
setup_ghostty

# Run installation script with shell choice
info "installing dependencies"
debug "Running machine-setup/unix/install.sh with shell: $SHELL_CHOICE"
if [ "$DRY_RUN" == "true" ]; then
  success "run machine-setup/unix/install.sh --shell $SHELL_CHOICE"
else
  if [ "$VERBOSE" == "true" ]; then
    # In verbose mode, show all output directly
    if sh machine-setup/unix/install.sh --shell "$SHELL_CHOICE"
    then
      success "dependencies installed"
    else
      warning "some dependencies failed to install (exit code: $?)"
      warning "continuing with bootstrap..."
    fi
  else
    # Normal mode: prefix each line with info
    if sh machine-setup/unix/install.sh --shell "$SHELL_CHOICE" 2>&1 | while read -r data; do info "$data"; done
    then
      success "dependencies installed"
    else
      warning "some dependencies failed to install"
      warning "continuing with bootstrap..."
    fi
  fi
fi

# Run optional macOS setup scripts
if [ "$(uname -s)" == "Darwin" ]; then
  if [ "$RUN_SET_DEFAULTS" == "true" ]; then
    info "applying macOS system defaults"
    if [ "$DRY_RUN" == "true" ]; then
      success "run machine-setup/mac/set-defaults.sh"
    else
      if sh machine-setup/mac/set-defaults.sh
      then
        success "macOS defaults applied"
      else
        fail "error applying macOS defaults"
      fi
    fi
  fi

  if [ "$RUN_SET_HOSTNAME" == "true" ]; then
    info "setting macOS hostname"
    if [ "$DRY_RUN" == "true" ]; then
      success "run machine-setup/mac/set-hostname.sh"
    else
      if sh machine-setup/mac/set-hostname.sh
      then
        success "macOS hostname set"
      else
        fail "error setting macOS hostname"
      fi
    fi
  fi
fi

echo ''
if [ "$DRY_RUN" == "true" ]; then
  echo '========================================='
  echo '  Dry run complete!'
  echo '  Run without --dry-run to apply changes'
  echo '========================================='
else
  echo '  All installed!'
fi
