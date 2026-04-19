---
description: Show the QuikGIF CLI version, license tier, app installation status, and MCP registration state.
allowed-tools: ["Bash"]
---

# /claude-quikgif:status

Print a human-readable summary of the QuikGIF CLI + MCP setup on this machine.

## Steps

1. Run the diagnostic with `Bash`:

   ```bash
   if command -v quikgif >/dev/null 2>&1; then
     quikgif --version
     echo
     quikgif mcp-status 2>/dev/null || true
   else
     echo "QuikGIF CLI not installed."
     echo "Install with: curl -fsSL https://quikgif.com/install.sh | sh"
   fi
   ```

2. If the CLI is installed and the QuikGIF MCP is connected in this session, also call the MCP's own `quikgif_status` tool — it returns CLI version, license tier, app detection, permissions, and direct upgrade / install URLs in structured JSON.

3. Summarize the result for the user. If the CLI is on an older version than `quikgif update --check` would advertise, suggest running `/claude-quikgif:update`.
