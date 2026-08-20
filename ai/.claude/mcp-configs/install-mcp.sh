#!/bin/bash
# Register global (user-scope) MCP servers with Claude Code from mcp-servers.json.
#
# Usage:
#   ./install-mcp.sh            # add any servers that are not already configured
#   ./install-mcp.sh --force    # remove and re-add every server (picks up config changes)
#
# Idempotent: existing servers are skipped unless --force is passed.
#
# Notes:
#   - stdio servers (context7, firebase, xcode, etc.) work immediately.
#   - http servers (notion, nerdz) are registered here but still need a one-time
#     interactive OAuth login afterwards:  claude mcp login notion && claude mcp login nerdz
#   - Prerequisites on the host: node/npx, uvx (for office-word), firebase CLI (for firebase).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/mcp-servers.json"
FORCE=false
[ "${1:-}" = "--force" ] && FORCE=true

if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI not found. Install Claude Code first." >&2
    exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found (needed to parse the config)." >&2
    exit 1
fi
if [ ! -f "$CONFIG" ]; then
    echo "Error: config not found: $CONFIG" >&2
    exit 1
fi

existing="$(claude mcp list 2>/dev/null || true)"

# Emit "name<TAB>json" per server.
python3 - "$CONFIG" <<'PY' | while IFS=$'\t' read -r name json; do
import json, sys
data = json.load(open(sys.argv[1]))
for n, cfg in data.get("mcpServers", {}).items():
    sys.stdout.write(f"{n}\t{json.dumps(cfg)}\n")
PY
    if echo "$existing" | grep -qE "^${name}:"; then
        if [ "$FORCE" = true ]; then
            echo "RE-ADD: $name"
            claude mcp remove "$name" -s user >/dev/null 2>&1 || true
        else
            echo "SKIP:   $name (already configured)"
            continue
        fi
    else
        echo "ADD:    $name"
    fi
    claude mcp add-json "$name" "$json" -s user >/dev/null
done

echo ""
echo "Done. Run 'claude mcp list' to verify."
echo "HTTP servers still need a one-time login, e.g.: claude mcp login notion"
