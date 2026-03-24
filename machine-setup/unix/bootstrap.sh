#!/usr/bin/env bash
#
# bootstrap installs things.

cd "$(dirname "$0")/../.."
DOTFILES_ROOT=$(pwd -P)

set -e

# Parse command line flags
RUN_SET_DEFAULTS=false
RUN_SET_HOSTNAME=false

usage() {
  echo "Usage: bootstrap.sh [options]"
  echo ""
  echo "Options:"
  echo "  -a, --all             Run all optional setup (defaults + hostname)"
  echo "  -d, --set-defaults    Run macOS set-defaults.sh (sets system preferences)"
  echo "  -n, --set-hostname    Run macOS set-hostname.sh (sets computer hostname)"
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

# Initialize git submodules
if [ -f .gitmodules ]; then
  echo "Initializing git submodules..."
  git submodule update --init --recursive
fi

echo ''

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

setup_gitconfig () {
  if ! [ -f config/unix/git/gitconfig.local.symlink ]
  then
    info 'setup gitconfig'

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

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

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

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
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
  mkdir -p "$HOME/.claude"

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

  # Create Ghostty config directory
  mkdir -p "$HOME/.config/ghostty"

  local overwrite_all=false backup_all=false skip_all=false

  # Symlink Ghostty config
  link_file "$DOTFILES_ROOT/config/unix/ghostty/config.symlink" "$HOME/.config/ghostty/config"

  success 'Ghostty configuration linked'
}

setup_gitconfig
install_dotfiles
setup_claude_code
setup_ghostty

# Run installation script
info "installing dependencies"
if sh machine-setup/unix/install.sh 2>&1 | while read -r data; do info "$data"; done
then
  success "dependencies installed"
else
  fail "error installing dependencies"
fi

# Run optional macOS setup scripts
if [ "$(uname -s)" == "Darwin" ]; then
  if [ "$RUN_SET_DEFAULTS" == "true" ]; then
    info "applying macOS system defaults"
    if sh machine-setup/mac/set-defaults.sh
    then
      success "macOS defaults applied"
    else
      fail "error applying macOS defaults"
    fi
  fi

  if [ "$RUN_SET_HOSTNAME" == "true" ]; then
    info "setting macOS hostname"
    if sh machine-setup/mac/set-hostname.sh
    then
      success "macOS hostname set"
    else
      fail "error setting macOS hostname"
    fi
  fi
fi

echo ''
echo '  All installed!'
