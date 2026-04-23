#!/bin/bash
# Clone all nerd skill repos into a single directory.
#
# Usage:
#   ./clone.sh                          # default: ~/Documents/PersonalProjects/nerd-skills
#   ./clone.sh /path/to/nerd-skills     # custom location
#
# Run this on a new machine before install.sh.

set -euo pipefail

TARGET="${1:-$HOME/Documents/PersonalProjects/nerd-skills}"
GITHUB="git@github.com:RomanKovalchukDev"

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

mkdir -p "$TARGET"

for skill in "${SKILLS[@]}"; do
    dest="$TARGET/$skill"
    if [ -d "$dest" ]; then
        echo "SKIP: $skill (already exists)"
        continue
    fi
    echo "Cloning $skill..."
    git clone "$GITHUB/$skill.git" "$dest"
done

echo ""
echo "Done. All skills cloned to $TARGET"
echo "Run install.sh to create symlinks."
