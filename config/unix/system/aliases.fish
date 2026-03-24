#!/usr/bin/env fish
# System aliases for Fish

# grc overrides for ls
# Made possible through contributions from generous benefactors like
# `brew install coreutils`
if command -v gls >/dev/null 2>&1
    alias ls="gls -F --color"
    alias l="gls -lAh --color"
    alias ll="gls -l --color"
    alias la="gls -A --color"
end
