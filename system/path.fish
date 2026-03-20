# System PATH configuration

# Local bins and dotfiles bin
fish_add_path -p ./bin
fish_add_path -p $HOME/.local/bin
fish_add_path -p /usr/local/bin
fish_add_path -p /usr/local/sbin
fish_add_path -p $DOTFILES/bin

# MANPATH
set -gx MANPATH /usr/local/man /usr/local/mysql/man /usr/local/git/man $MANPATH
