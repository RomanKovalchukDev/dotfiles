#!/usr/bin/env fish
#
# Fish configuration
#

# Set dotfiles root
# Bootstrap creates a ~/.dotfiles symlink pointing to the actual dotfiles location
set -gx DOTFILES_ROOT $HOME/.dotfiles

# 1. PATH configurations
# Use Bass for PATH since it's environment setup
if type -q bass
    if test -f $DOTFILES_ROOT/config/unix/system/_path.zsh
        bass source $DOTFILES_ROOT/config/unix/system/_path.zsh
    end
end

# 2. Environment variables
if test -f $DOTFILES_ROOT/config/unix/editors/env.fish
    source $DOTFILES_ROOT/config/unix/editors/env.fish
end

# 3. Atuin (history) - use native Fish integration
if command -v atuin >/dev/null 2>&1
    atuin init fish | source
end

# 4. Load Fish aliases
if test -f $DOTFILES_ROOT/config/unix/system/aliases.fish
    source $DOTFILES_ROOT/config/unix/system/aliases.fish
end

if test -f $DOTFILES_ROOT/config/unix/docker/aliases.fish
    source $DOTFILES_ROOT/config/unix/docker/aliases.fish
end

if test -f $DOTFILES_ROOT/config/unix/git/aliases.fish
    source $DOTFILES_ROOT/config/unix/git/aliases.fish
end

# Note: Skipping ZSH-specific configs that don't translate to Fish:
# - system/grc.zsh (uses ZSH-specific syntax)
# - system/keys.zsh (ZSH keybindings)
# - zsh/* (ZSH-specific configuration)

# Load local config if it exists
if test -f $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end
