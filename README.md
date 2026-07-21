# claude-quikgif

A [Claude Code](https://claude.com/product/claude-code) plugin that wires up the [QuikGIF](https://quikgif.com) MCP server and manages CLI lifecycle (install, update, status, MCP registration) — so you can record polished, scripted GIF demos directly from inside Claude Code.

## What you get

- **QuikGIF MCP server, auto-connected.** The plugin bundles its own copy of the QuikGIF MCP shim, so as soon as you install the plugin, Claude Code can invoke any of the QuikGIF MCP tools (`quikgif_status`, `start_recording`, `record_region`, `render_gif`, `execute_script`, etc.). When the QuikGIF CLI is also installed locally, the plugin transparently uses it; when it isn't, the bundled shim returns a `quikgif_install_help` tool with install instructions.
- **Update notice on session start.** Once every six hours, the plugin runs `quikgif update --check` against the releases worker and prints a one-line notice if a newer CLI is available. Silent otherwise.
- **Lifecycle slash commands** for first-time install, in-place update, MCP re-registration, and diagnostic status.

## Prerequisites

- macOS 14.0+ (QuikGIF is macOS-only)
- [Claude Code](https://code.claude.com/docs/en/quickstart) with plugin support
- *(Optional but recommended)* The QuikGIF CLI, installed via `curl -fsSL https://quikgif.com/install.sh | sh`. The plugin works without it (you'll get install-help responses), but recording requires the binary.

## Install

```bash
claude plugin marketplace add robworks-code/robworks-claude-code-plugins
claude plugin install claude-quikgif@robworks-claude-code-plugins
```

Or, inside an interactive Claude Code session:

```
/plugin install claude-quikgif@robworks-claude-code-plugins
```

After install, restart Claude Code so the MCP host launches the bundled QuikGIF MCP server.

## Slash commands

| Command | What it does |
| --- | --- |
| `/claude-quikgif:status` | Print CLI version, license tier, app detection, and MCP registration state for all detected hosts. |
| `/claude-quikgif:install` | Run the canonical curl installer to install/repair the QuikGIF CLI. |
| `/claude-quikgif:update` | Run `quikgif update` to fetch the latest signed binary, verify SHA256 + codesign, and atomically replace. |
| `/claude-quikgif:install-mcp` | Re-run `quikgif mcp-install --yes` to refresh the user-managed shim across all detected MCP hosts. |

## How update management works

- The plugin's `SessionStart` hook (`hooks/scripts/check-cli-version.sh`) runs once every six hours per machine. It calls `quikgif update --check`, captures the output, and only emits a one-line notice when a newer version is available.
- The throttle marker lives at `~/.cache/claude-quikgif/last-update-check`. Delete it to force an immediate re-check.
- The plugin itself is versioned through the Robworks marketplace — `claude plugin update claude-quikgif@robworks-claude-code-plugins` pulls plugin-side updates (new commands, hook tweaks, refreshed bundled shim).
- Plugin updates and CLI updates are independent: the plugin manages how Claude Code talks to QuikGIF; the CLI is what actually records.

## How the MCP wiring works

The plugin's `.mcp.json` registers a single `quikgif` MCP server pointing at a launcher script. The launcher prefers the user-managed shim at `~/.local/share/quikgif/mcp-shim.sh` (kept current by `quikgif mcp-install`), and falls back to a bundled copy inside the plugin itself. Both shims behave identically: they exec `quikgif mcp-server` if the CLI is on disk, and serve a minimal install-help MCP stub if it isn't.

If you've already run `quikgif mcp-install`, you'll have a `quikgif` entry in your `~/.claude.json` from that flow AND the plugin's `quikgif` entry. Claude Code de-duplicates by name; both point at the same shim so behavior is identical.

## Uninstall

```bash
claude plugin uninstall claude-quikgif@robworks-claude-code-plugins
```

This removes the plugin's MCP entry from Claude Code. It does NOT touch the QuikGIF CLI binary or the user-managed shim — to fully remove QuikGIF, run `curl -fsSL https://quikgif.com/install.sh | sh -s -- --uninstall` and `quikgif mcp-uninstall` first.

## Links

- QuikGIF homepage: https://quikgif.com
- QuikGIF CLI source: https://github.com/ringo380/quikgif
- Plugin source: https://github.com/ringo380/claude-quikgif
- Marketplace: https://github.com/robworks-code/robworks-claude-code-plugins

## License

MIT
