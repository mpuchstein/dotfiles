# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Quickshell (v0.2.x) desktop shell configuration for Hyprland on Arch Linux. It renders a vertical bar on the right edge of the screen with popout panels. Written entirely in QML using Quickshell's extended Qt Quick modules.

## Running / Reloading

```bash
quickshell                    # launch (reads shell.qml from ~/.config/quickshell/)
quickshell -c /path/to/dir    # launch from a different config dir
```

Quickshell hot-reloads on file save — no restart needed during development. If the shell crashes or gets stuck, `killall quickshell && quickshell &` to restart.

## Architecture

### Entry Point

`shell.qml` — `ShellRoot` that instantiates three top-level components:
1. `NotificationDaemon` — D-Bus notification server
2. `Bar` — the main bar + popout overlay
3. `Osd` — volume/mic OSD overlay

### Bar (`Bar.qml`)

Uses `Variants` over `Quickshell.screens` to create per-monitor `PanelWindow` instances (filtered to `Config.monitor`). Two window layers:
- **Bar window** — fixed-width right-anchored panel with pill-shaped widgets
- **Popout window** — transparent overlay with animated `PopoutSlot` components that appear left of the bar

Bar pills (notification, workspaces, weather, datetime, system) toggle popouts via the `PopoutState` singleton.

### Shared Singletons (`shared/`)

All four are `pragma Singleton`:
- **Config** — user settings (monitor=DP-2, weatherLocation=Nospelt, power commands, disk mounts, formats); `.tmpl` file driven by chezmoi data
- **Theme** — Apex-neon/aeon colors (replaces Catppuccin), layout constants, typography (GeistMono Nerd Font), animation durations
- **PopoutState** — which popout is active (`active` string + `triggerY`), with `toggle()`/`close()`
- **Time** — `SystemClock`-backed formatted time strings
- **Weather** — fetches from `wttr.in`, parses JSON, exposes current + forecast data

### Popout Pattern

Each popout follows the same structure:
1. A `BarPill` in the bar column (toggles `PopoutState`)
2. A `PopoutSlot` in `Bar.qml` (handles animation — fade, scale, slide)
3. A popout component in `bar/popouts/` wrapped in `PopoutBackground` (rounded left, flush right)

### Data Fetching

`SystemPopout` polls system stats via `Process` + `StdioCollector`:
- CPU, memory, temperature, GPU (via `scripts/gpu.sh`), disk, network, updates
- Different refresh intervals: 5s (CPU/mem/temp/GPU), 30s (disk/net), 5min (updates)

Weather uses `curl wttr.in` with a 30-minute refresh timer.

### Quickshell-Specific Patterns

- `Variants { model: Quickshell.screens }` — per-screen window instantiation
- `PanelWindow` with `anchors`/`margins`/`exclusiveZone` — Wayland layer-shell positioning
- `Scope` — non-visual Quickshell container for grouping logic
- `Process` + `StdioCollector { onStreamFinished }` — async shell command execution
- `PwObjectTracker` — required to track PipeWire default sink/source changes
- `Quickshell.Hyprland` — workspace state and `Hyprland.dispatch()` for IPC

### Key Dependencies

- **Hyprland** — compositor (workspace switching, IPC)
- **PipeWire** — audio control (volume, mute)
- **wttr.in** — weather data (no API key needed)
- **lm_sensors** (`sensors`) — CPU temperature
- **Nerd Fonts** (GeistMono Nerd Font) — all icons are Unicode Nerd Font glyphs
- **hyprlock** / **hypridle** / **hyprshutdown** — lock, idle, power actions

## Conventions

- Icons: Nerd Font Unicode escapes (`"\u{f057e}"`) — not icon names or image files
- Colors: always reference `Shared.Theme.*` (apex-neon palette by default; apex-aeon for light mode)
- Layout: use `Shared.Theme.*` constants for sizing, spacing, radii
- Config: user-facing settings go in `Config.qml`, not hardcoded in components
- Animations: use `Behavior on <prop>` with `Shared.Theme.animFast/animNormal/animSlow`
- Inline components: `component Foo: ...` inside a file for file-local reusable types (see `SystemPopout`)
- Popout panels consume mouse clicks with a root `MouseArea` to prevent click-through closing
