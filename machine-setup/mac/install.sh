#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

cd "$(dirname $0)"/../..

echo "› brew bundle"
brew bundle --file=machine-setup/mac/Brewfile

# find the installers and run them iteratively
find config/mac -name install.sh | while read installer ; do sh -c "${installer}" ; done
