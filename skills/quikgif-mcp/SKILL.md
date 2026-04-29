---
name: QuikGIF MCP
description: Use when the user wants to record a GIF, capture a window or screen region, automate a screen demo, write a .qgif script, process or render a GIF, or use any QuikGIF MCP tool. Also activates when diagnosing QuikGIF MCP connection issues or asking what QuikGIF can do.
---

# QuikGIF MCP

QuikGIF exposes a full MCP server (`quikgif mcp-server`, stdio transport) with 21 tools and 5 resources for GIF recording, scripting, and post-processing on macOS.

## First call: always `quikgif_status`

When anything seems off (missing tools, connection errors, permission failures), call `quikgif_status` first. It returns CLI version, license tier (free/pro), app detection, permission status, and install/upgrade URLs in structured JSON. It always succeeds.

## Tool Reference

### Recording
| Tool | What it does |
|------|-------------|
| `start_recording` | Record a window by ID. Returns `sessionId`. |
| `record_region` | Record an absolute screen region by x/y/width/height. Returns `sessionId`. |
| `stop_recording` | Stop a session. Frames are preserved for `render_gif`. |
| `pause_recording` | Pause (note: SCStream keeps running; for true pause use stop+start). |
| `resume_recording` | Resume a paused session. |

**Key parameters for `start_recording`**: `windowId` (from `list_windows`), `duration` (seconds, optional — omit for manual stop), `fps` (default 30), `showCursor`.

**Key parameters for `record_region`**: `x`, `y`, `width`, `height` (all in screen points), `duration`, `fps`.

### Rendering
| Tool | What it does |
|------|-------------|
| `render_gif` | Convert a session's frames to a GIF/WebP/APNG/MP4. Accepts post-processing options. |
| `process_gif` | Post-process an existing file: resize, speed, idle handling. |

**Key parameters for `render_gif`**: `sessionId`, `outputPath`, `format` (`gif`/`webp`/`apng`/`mp4`), `maxWidth`, `fps`, `cursorSmoothing`, `clickIndicators`, `keystrokeBadges`, `idleStrategy` (`fade`/`cut`/`ramp`).

### Input Simulation (for demo automation)
| Tool | What it does |
|------|-------------|
| `type_text` | Simulate typing with human-like pacing. Optional `pressEnter`. |
| `click` | Click at x/y coordinates (omit both to click current cursor position). |
| `move_cursor` | Move cursor to x/y. Optional `animate` for smooth movement. |
| `key_press` | Press a key with modifiers. Combine with `+`: `cmd+c`, `shift+tab`. |
| `scroll` | Scroll in a direction (`up`/`down`/`left`/`right`) at current cursor. |

### Windows & Apps
| Tool | What it does |
|------|-------------|
| `list_windows` | List capturable windows. Optional `appName` filter. Returns `windowId`. |
| `open_app` | Open an app. Returns new `windowId`. Creates new window even if already running. |
| `focus_app` | Bring an app to the front. |

### Scripting
| Tool | What it does |
|------|-------------|
| `execute_script` | Run a `.qgif` script inline (`script` param) or from a file (`scriptPath`). |
| `validate_script` | Dry-run validate a `.qgif` script for syntax errors before executing. |

### Info & Diagnostics
| Tool | What it does |
|------|-------------|
| `quikgif_status` | Diagnostic snapshot: version, tier, app, permissions, URLs. Always succeeds. |
| `check_permissions` | Screen Recording and Accessibility permission status. |
| `list_settings` | All `.qgif` script settings with types, defaults, descriptions. |
| `list_commands` | All `.qgif` script commands with syntax. |

## Resources

- `quikgif://docs/scripting-reference` — full `.qgif` DSL reference
- `quikgif://examples/{name}` — example scripts: `hello`, `git-workflow`, `multi-window`, `spotlight-demo`, `polish-demo`
- `quikgif://schema/settings` — settings schema with types and defaults
- `quikgif://status/permissions` — permission status JSON
- `quikgif://recordings` — recent GIF output list

Fetch a resource to learn the scripting syntax before writing a `.qgif` script.

## Common Workflows

### Record a window demo

```
1. list_windows (get windowId)
2. open_app / focus_app as needed
3. start_recording (windowId, duration or omit for manual)
4. type_text / click / key_press to drive the demo
5. stop_recording
6. render_gif (sessionId, outputPath, options)
```

### Record a screen region

```
1. record_region (x, y, width, height, duration)
2. type_text / click to drive content
3. stop_recording
4. render_gif (sessionId, outputPath)
```

### Run a .qgif script (easiest for multi-step demos)

```
1. (optional) Read quikgif://docs/scripting-reference or quikgif://examples/hello
2. validate_script (script source)
3. execute_script (script source or scriptPath)
```

### Post-process an existing GIF

```
process_gif (inputPath, outputPath, maxWidth, speed, idleStrategy)
```

## .qgif Scripting Language

The `.qgif` DSL drives recordings declaratively. Key commands:

```qgif
# Setup
set fps 24
set max-width 800
set output ~/Desktop/demo.gif
set pace demo          # tutorial | demo | cinematic
set cursor-smoothing true
set keystroke-badges true

# Window / app
open "Terminal" into $term
record $term duration 15 continue   # records while script continues

# Input
type "git status"
key return
wait 1.5
click 100 200
scroll down

# Timing
wait 0.5
remain                 # wait for remaining record duration

# Scripting
set $var "value"
run "shell command"
```

Use `execute_script` with `script:` for inline scripts, `scriptPath:` for `.qgif` files.
Use `validate_script` before `execute_script` to catch syntax errors.

## Free vs Pro

- **Free**: recording duration capped at 30 seconds. Output format: GIF only.
- **Pro**: unlimited duration, all output formats (WebP, APNG, MP4), advanced transforms.

Check tier via `quikgif_status` → `tier` field. Upgrade at `https://quikgif.com/pro`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Only `quikgif_install_help` tool visible | CLI not installed. Run `/claude-quikgif:install`. |
| `check_permissions` returns false | Screen Recording not granted. Open System Settings → Privacy → Screen Recording → toggle QuikGIF. |
| MCP disconnected | Run `/claude-quikgif:install-mcp`, then restart Claude Code. |
| `render_gif` produces large file | Add `maxWidth: 800`, `fps: 15`, or `idleStrategy: cut`. |
| Recording captures wrong window | Run `list_windows` to verify `windowId`; use `focus_app` first. |
