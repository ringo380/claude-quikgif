#!/bin/sh
# claude-quikgif SessionStart hook: surface a one-line notice if a newer
# QuikGIF CLI is available. Silent otherwise. Self-throttled to one network
# check every 6 hours so multi-session days don't hammer the releases worker.

set -u

# No CLI on this machine? Plugin still works (via bundled MCP install-help
# stub), but there's nothing to update — skip silently.
if ! command -v quikgif >/dev/null 2>&1; then
    exit 0
fi

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-quikgif"
MARKER="$CACHE_DIR/last-update-check"
THROTTLE_SECONDS=21600  # 6h

mkdir -p "$CACHE_DIR" 2>/dev/null || exit 0

if [ -f "$MARKER" ]; then
    last=$(stat -f %m "$MARKER" 2>/dev/null || echo 0)
    now=$(date +%s)
    if [ "$((now - last))" -lt "$THROTTLE_SECONDS" ]; then
        exit 0
    fi
fi
touch "$MARKER" 2>/dev/null

# Capture output; only emit if a newer version is available.
out=$(quikgif update --check 2>&1) || true
case "$out" in
    *"New version available"*)
        # Print only the two actionable lines (skip "Checking for updates...").
        echo ""
        echo "[claude-quikgif] $(echo "$out" | grep -E 'New version|Run ' | tr '\n' ' ')"
        echo ""
        ;;
esac
exit 0
