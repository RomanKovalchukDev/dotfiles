#!/usr/bin/env fish
# PATH configuration for Fish

# Add dotfiles bin to PATH
if test -d $DOTFILES_ROOT/config/unix/bin
    set -gx PATH $DOTFILES_ROOT/config/unix/bin $PATH
end
