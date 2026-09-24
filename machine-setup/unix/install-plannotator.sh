#!/bin/bash
# Installs the plannotator binary into ~/.local/bin. Skills, hooks and slash commands
# are deliberately skipped: ~/.claude is symlinked into the dotclaude repository, so an
# installer writing there would land inside a git working tree. dotclaude owns the skills
# through config/skills.manifest.
set -e

PLANNOTATOR_VERSION="${PLANNOTATOR_VERSION:-0.27.12}"
PLANNOTATOR_BIN="$HOME/.local/bin/plannotator"

installed_version() {
  [ -x "$PLANNOTATOR_BIN" ] || return 1
  "$PLANNOTATOR_BIN" --version 2>/dev/null | awk '{print $2}'
}

current="$(installed_version || true)"
if [ "$current" = "$PLANNOTATOR_VERSION" ]; then
  echo "plannotator $current already installed"
  exit 0
fi

if [ -n "$current" ]; then
  echo "plannotator $current installed, moving to $PLANNOTATOR_VERSION"
fi

curl -fsSL https://plannotator.ai/install.sh | bash -s -- --minimal --version "$PLANNOTATOR_VERSION"

after="$(installed_version || true)"
if [ "$after" != "$PLANNOTATOR_VERSION" ]; then
  echo "plannotator: expected $PLANNOTATOR_VERSION, found '${after:-nothing}' at $PLANNOTATOR_BIN" >&2
  exit 1
fi
echo "plannotator $after installed"
