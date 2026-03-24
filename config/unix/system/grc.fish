#!/usr/bin/env fish
# GRC colorizes nifty unix tools all over the place

if command -v grc >/dev/null 2>&1; and command -v brew >/dev/null 2>&1
    set -l grc_bashrc (brew --prefix)/etc/grc.fish
    if test -f $grc_bashrc
        source $grc_bashrc
    end
end
