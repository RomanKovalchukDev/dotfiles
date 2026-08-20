#!/bin/bash
# Register Claude Code plugin marketplaces and install plugins from plugins.manifest.
#
# Usage:
#   ./install-plugins.sh
#
# Idempotent: marketplaces/plugins already present are skipped. Plugins stay
# owned by their authors (installed via marketplace); nothing is vendored here.
#
# Prerequisite: Claude Code CLI on PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/plugins.manifest"

if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI not found. Install Claude Code first." >&2
    exit 1
fi
if [ ! -f "$MANIFEST" ]; then
    echo "Error: manifest not found: $MANIFEST" >&2
    exit 1
fi

markets_now="$(claude plugin marketplace list 2>/dev/null || true)"
plugins_now="$(claude plugin list 2>/dev/null || true)"

while read -r kind value; do
    # skip blanks and comments
    [ -z "${kind:-}" ] && continue
    case "$kind" in \#*) continue ;; esac

    case "$kind" in
        marketplace)
            # marketplace name is the repo basename (owner/repo -> repo)
            name="${value##*/}"
            if echo "$markets_now" | grep -q "$name"; then
                echo "SKIP market: $value (already added)"
            else
                echo "ADD  market: $value"
                claude plugin marketplace add "$value" --scope user || \
                    echo "WARN: failed to add marketplace $value"
            fi
            ;;
        plugin)
            # value is plugin@marketplace; match on the plugin name
            pname="${value%@*}"
            if echo "$plugins_now" | grep -q "$pname"; then
                echo "SKIP plugin: $value (already installed)"
            else
                echo "INST plugin: $value"
                claude plugin install "$value" -s user || \
                    echo "WARN: failed to install plugin $value"
            fi
            ;;
        *)
            echo "WARN: unknown directive '$kind' (line ignored)"
            ;;
    esac
done < "$MANIFEST"

echo ""
echo "Done. Verify with: claude plugin marketplace list && claude plugin list"
