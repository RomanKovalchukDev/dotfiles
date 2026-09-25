#!/bin/bash
# Hand a Raycast settings export to Raycast so it can import it.
#
# Raycast keeps its hotkey, aliases, quicklinks and extension settings in an
# encrypted database, not in defaults, so none of it can be written by a script.
# The supported route is Settings > Advanced > Export Preferences on the old
# machine, which produces a .rayconfig, then importing that on the new one.
#
# The export can carry extension credentials, so it is never committed here.
# Keep it outside the repository and point RAYCAST_CONFIG at it, or drop it in
# <parent-of-dotfiles>/private/ where this script looks by default.
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEFAULT_DIR="$(dirname "$DOTFILES_ROOT")/private"

config="${1:-${RAYCAST_CONFIG:-}}"

if [ -z "$config" ]; then
  config="$(find "$DEFAULT_DIR" -maxdepth 1 -name '*.rayconfig' 2> /dev/null | head -1 || true)"
fi

if [ -z "$config" ] || [ ! -f "$config" ]; then
  echo "  no .rayconfig found, skipping Raycast import"
  echo "  export one from the old machine: Raycast > Settings > Advanced > Export Preferences"
  echo "  then re run with: RAYCAST_CONFIG=/path/to/file.rayconfig $0"
  exit 0
fi

if [ ! -d "/Applications/Raycast.app" ]; then
  echo "  Raycast is not installed, skipping import (it comes from the Brewfile)"
  exit 0
fi

echo "  opening $config in Raycast"
echo "  Raycast will ask you to confirm, and for the password if the export was encrypted"
open -a Raycast "$config"
