---
description: Run `quikgif mcp-install` to (re)register the QuikGIF MCP shim with this AI host. Use after a fresh CLI install or to refresh stale shim entries.
allowed-tools: ["Bash"]
---

# /claude-quikgif:install-mcp

Re-register the QuikGIF MCP shim. The plugin already bundles a working MCP server (via `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/launch-mcp.sh`), but running `quikgif mcp-install` writes the canonical user-managed shim at `~/.local/share/quikgif/mcp-shim.sh` so other AI hosts (Cursor, Windsurf, VS Code, Claude Desktop) also pick it up.

## Steps

1. Confirm the CLI is present:

   ```bash
   command -v quikgif >/dev/null 2>&1 && quikgif --version | head -1 || { echo "quikgif CLI not installed — run /claude-quikgif:install first"; exit 1; }
   ```

2. Run the installer (idempotent — short-circuits if every detected client already points at the current shim):

   ```bash
   quikgif mcp-install --yes
   ```

3. Tell the user which clients were updated. If any show `upgraded to fallback-aware shim`, those clients had a legacy entry pointing at the bare `quikgif` binary; the install just migrated them to the shim that surfaces install-help when the CLI goes missing.

4. Remind the user to **restart Claude Code** (and any other affected hosts) so they re-launch the MCP server against the refreshed entry.
