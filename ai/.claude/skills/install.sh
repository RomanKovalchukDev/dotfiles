#!/bin/bash
# Install nerd skills by creating symlinks from ~/.claude/skills/ to local repos.
#
# Usage:
#   ./install.sh                          # default: ~/Documents/PersonalProjects/nerd-skills
#   ./install.sh /path/to/nerd-skills     # custom location
#
# Run this after cloning dotfiles on a new machine. Prerequisites:
#   1. Clone all nerd-* repos into one directory (or run clone.sh first)
#   2. Run this script to create symlinks

set -euo pipefail

SKILLS_SOURCE="${1:-$HOME/Documents/PersonalProjects/nerd-skills}"
SKILLS_TARGET="$HOME/.claude/skills"

SKILLS=(
    nerd-ios-setup
    nerd-swift-architecture
    nerd-swift-code-review
    nerd-swift-codestyle
    nerd-swift-concurrency
    nerd-swift-docc
    nerd-swift-gen-api
    nerd-swift-gen-component
    nerd-swift-gen-screen
    nerd-swift-networking
    nerd-swift-security
    nerd-swift-testing
    nerd-swiftui-view
)

if [ ! -d "$SKILLS_SOURCE" ]; then
    echo "Error: Skills source directory not found: $SKILLS_SOURCE"
    echo "Clone the skill repos first, or pass the correct path."
    exit 1
fi

mkdir -p "$SKILLS_TARGET"

for skill in "${SKILLS[@]}"; do
    src="$SKILLS_SOURCE/$skill"
    dest="$SKILLS_TARGET/$skill"

    if [ ! -d "$src" ]; then
        echo "SKIP: $skill (not found in $SKILLS_SOURCE)"
        continue
    fi

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -d "$dest" ]; then
        echo "WARN: $dest exists and is not a symlink, skipping"
        continue
    fi

    ln -s "$src" "$dest"
    echo "OK:   $skill -> $src"
done

echo ""
echo "Done. Skills linked to $SKILLS_TARGET"
