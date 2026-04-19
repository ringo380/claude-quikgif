#!/bin/sh
# claude-quikgif MCP launcher.
# Prefer the user-installed shim (kept current by `quikgif mcp-install`),
# falling back to the bundled copy inside this plugin so the MCP works
# even if the user never ran mcp-install.

set -u

USER_SHIM="$HOME/.local/share/quikgif/mcp-shim.sh"
BUNDLED_SHIM="${CLAUDE_PLUGIN_ROOT}/hooks/scripts/mcp-shim.sh"

if [ -x "$USER_SHIM" ]; then
    exec "$USER_SHIM" "$@"
fi

if [ -x "$BUNDLED_SHIM" ]; then
    exec "$BUNDLED_SHIM" "$@"
fi

# Both missing — emit a clear error to stderr and exit so the MCP host
# surfaces a useful message instead of a generic spawn failure.
echo "[claude-quikgif] No MCP shim found." 1>&2
echo "[claude-quikgif] Looked at $USER_SHIM and $BUNDLED_SHIM." 1>&2
echo "[claude-quikgif] Reinstall the plugin or run: curl -fsSL https://quikgif.com/install.sh | sh && quikgif mcp-install --yes" 1>&2
exit 127
