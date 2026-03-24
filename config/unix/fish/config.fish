#!/usr/bin/env fish
#
# Fish configuration using Bass to source ZSH configs
#
# This allows Fish to use all ZSH configurations through the Bass plugin

# Set dotfiles root
# Bootstrap creates a ~/.dotfiles symlink pointing to the actual dotfiles location
set -gx DOTFILES_ROOT $HOME/.dotfiles

# Check if Bass is installed
if not type -q bass
    echo "Bass plugin not installed. Run: fisher install edc/bass"
    exit 1
end

# Source ZSH configs in order using Bass
# 1. Path configurations first
if test -f $DOTFILES_ROOT/config/unix/system/_path.zsh
    bass source $DOTFILES_ROOT/config/unix/system/_path.zsh
end

# 2. Environment variables
bass source $DOTFILES_ROOT/config/unix/system/env.zsh
bass source $DOTFILES_ROOT/config/unix/editors/env.zsh
bass source $DOTFILES_ROOT/config/unix/atuin/env.zsh

# 3. Load other ZSH configs
bass source $DOTFILES_ROOT/config/unix/system/aliases.zsh
bass source $DOTFILES_ROOT/config/unix/system/grc.zsh
bass source $DOTFILES_ROOT/config/unix/system/keys.zsh
bass source $DOTFILES_ROOT/config/unix/docker/aliases.zsh
bass source $DOTFILES_ROOT/config/unix/git/aliases.zsh
bass source $DOTFILES_ROOT/config/unix/zsh/aliases.zsh
bass source $DOTFILES_ROOT/config/unix/zsh/config.zsh

# 4. Completion configurations last
# Note: Fish has its own completion system, ZSH completions may not work
# bass source $DOTFILES_ROOT/config/unix/git/completion.zsh
# bass source $DOTFILES_ROOT/config/unix/zsh/completion.zsh

# Note: Skipping ZSH-specific configs that don't apply to Fish:
# - zsh/fpath.zsh (Fish doesn't use fpath)
# - zsh/prompt.zsh (Fish has its own prompt system)
# - zsh/window.zsh (Fish handles window titles differently)

# Load local config if it exists
if test -f $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end
