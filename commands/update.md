---
description: Update the QuikGIF CLI to the latest version (downloads and replaces the binary atomically; refuses on Homebrew installs).
allowed-tools: ["Bash"]
---

# /claude-quikgif:update

Run `quikgif update` to fetch the latest signed, notarized CLI binary, verify its SHA256 + Developer ID signature, and atomically replace the in-place binary.

## Steps

1. First, sanity-check the current version with `Bash`:

   ```bash
   quikgif --version | head -1
   ```

2. Run the update:

   ```bash
   quikgif update
   ```

   This handles:
   - Resolving the binary path
   - Fetching `quikgif-releases` worker `/download` (binary) + `/download/sha256` (digest)
   - SHA256 verification (required — no fallback)
   - Codesign verification (`anchor apple generic and certificate leaf[subject.OU] = "24XQM82CR6"`)
   - Atomic replace via `sudo /usr/bin/install` for write-protected destinations like `/usr/local/bin`

3. If the command exits non-zero with the Homebrew warning, run `curl -fsSL https://quikgif.com/install.sh | sh` instead — that script removes the Cellar install and replaces it with a current Developer-ID-signed binary.

4. After a successful update, advise the user to **restart Claude Code** so the MCP host re-launches the new `quikgif mcp-server`.

## Common failure modes

- "Homebrew-managed binary": run the curl install (see step 3).
- "Could not reach the releases server": transient — retry, or check `https://quikgif-releases.ringo380.workers.dev/latest` directly.
- "Codesign verify failed": signal of a tampered or partial download — re-run `quikgif update`; if it persists, file an issue.
