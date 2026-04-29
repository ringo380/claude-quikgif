---
name: install
description: Install the QuikGIF CLI for the first time or repair a broken install. Use when the user asks to install QuikGIF, when quikgif is not found on PATH, or when the binary produces signature errors.
allowed-tools: ["Bash"]
---

# /claude-quikgif:install

Install (or repair) the QuikGIF CLI binary on this machine. Use this when:

- `quikgif` is not on the user's PATH
- The CLI is on PATH but produces signature errors
- The user wants to migrate off the deprecated Homebrew tap

## What this does

Runs `curl -fsSL https://quikgif.com/install.sh | sh`, which:

1. Detects a prior Homebrew install and runs `brew uninstall quikgif` (silently with notice)
2. Downloads the current Developer-ID-signed binary from the releases worker
3. Verifies codesign with team ID `24XQM82CR6`
4. Installs to `/usr/local/bin` (with sudo) or `~/.local/bin` (no sudo)

## Steps

1. Confirm the user actually wants to run a `curl | sh` install (it requires sudo for `/usr/local/bin`). The script is open source at `https://github.com/ringo380/quikgif/blob/main/docs/install.sh`.

2. Run with `Bash`:

   ```bash
   curl -fsSL https://quikgif.com/install.sh | sh
   ```

3. After install, verify with `quikgif --version` and offer to run `/claude-quikgif:install-mcp` so Claude Code's MCP picks up the new binary.

4. Remind the user to **restart Claude Code** so the MCP host re-launches against the freshly installed CLI.
