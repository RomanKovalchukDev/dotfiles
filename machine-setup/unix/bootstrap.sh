#!/usr/bin/env bash
#
# bootstrap installs things.

cd "$(dirname "$0")/../.."
DOTFILES_ROOT=$(pwd -P)

set -e

# Parse command line flags
RUN_SET_DEFAULTS=false
RUN_SET_HOSTNAME=false
DRY_RUN=false
AUTO_MODE=""

usage() {
  echo "Usage: bootstrap.sh [options]"
  echo ""
  echo "Options:"
  echo "  -a, --all             Run all optional setup (defaults + hostname)"
  echo "  -d, --set-defaults    Run macOS set-defaults.sh (sets system preferences)"
  echo "  -n, --set-hostname    Run macOS set-hostname.sh (sets computer hostname)"
  echo "  -o, --overwrite-all   Automatically overwrite existing files without prompting"
  echo "  -b, --backup-all      Automatically backup existing files without prompting"
  echo "  --dry-run             Preview what would be done without making changes"
  echo "  -h, --help            Show this help message"
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
    -o|--overwrite-all)
      AUTO_MODE="overwrite"
      shift
      ;;
    -b|--backup-all)
      AUTO_MODE="backup"
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
    warning "~/.config is a broken symlink, removing it..."
    rm "$HOME/.config"
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
  if ! [ -f config/unix/git/gitconfig.local.symlink ]
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

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then
    # Check if already correctly linked
    local currentSrc="$(readlink $dst 2>/dev/null || echo '')"

    if [ "$currentSrc" == "$src" ]
    then
      skip=true;
    else
      # Handle AUTO_MODE first
      if [ "$AUTO_MODE" == "overwrite" ]; then
        overwrite_all=true
        overwrite=true
      elif [ "$AUTO_MODE" == "backup" ]; then
        backup_all=true
        backup=true
      elif [ "$overwrite_all" != "true" ] && [ "$backup_all" != "true" ] && [ "$skip_all" != "true" ]
      then
        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
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

      overwrite=${overwrite:-$overwrite_all}
      backup=${backup:-$backup_all}
      skip=${skip:-$skip_all}

      if [ "$overwrite" == "true" ]
      then
        if [ "$DRY_RUN" == "true" ]; then
          success "remove $dst"
        else
          rm -rf "$dst"
          success "removed $dst"
        fi
      fi

      if [ "$backup" == "true" ]
      then
        if [ "$DRY_RUN" == "true" ]; then
          success "move $dst to ${dst}.backup"
        else
          mv "$dst" "${dst}.backup"
          success "moved $dst to ${dst}.backup"
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

  local overwrite_all=false backup_all=false skip_all=false

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

  local overwrite_all=false backup_all=false skip_all=false

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

  local overwrite_all=false backup_all=false skip_all=false

  # Symlink Ghostty config
  debug "Linking ghostty config from $DOTFILES_ROOT/config/unix/ghostty/config to $HOME/.config/ghostty/config"
  link_file "$DOTFILES_ROOT/config/unix/ghostty/config" "$HOME/.config/ghostty/config"

  success 'Ghostty configuration linked'
}

setup_gitconfig
install_dotfiles
setup_claude_code
setup_ghostty

# Run installation script
info "installing dependencies"
debug "Running machine-setup/unix/install.sh..."
if [ "$DRY_RUN" == "true" ]; then
  success "run machine-setup/unix/install.sh"
else
  if [ "$VERBOSE" == "true" ]; then
    # In verbose mode, show all output directly
    if sh machine-setup/unix/install.sh
    then
      success "dependencies installed"
    else
      fail "error installing dependencies"
    fi
  else
    # Normal mode: prefix each line with info
    if sh machine-setup/unix/install.sh 2>&1 | while read -r data; do info "$data"; done
    then
      success "dependencies installed"
    else
      fail "error installing dependencies"
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
