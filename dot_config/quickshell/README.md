# Quickshell Desktop Shell

A vertical bar + popout panel shell for Hyprland, built with Quickshell v0.2.x and themed with Catppuccin.

## Setup

```bash
quickshell   # launch (reads from ~/.config/quickshell/)
```

Quickshell hot-reloads on file save. If it crashes: `killall quickshell && quickshell &`

## Configuration

All user settings live in **`shared/Config.qml`**. Edit this file to customize your setup:

| Setting | Default | Description |
|---------|---------|-------------|
| `catppuccinFlavor` | `"mocha"` | Color theme: `"mocha"`, `"macchiato"`, `"frappe"`, `"latte"` |
| `transparency` | `true` | Semi-transparent bar/popouts (requires Hyprland layerrules below) |
| `monitor` | `"DP-1"` | Which monitor to display the bar on |
| `workspaceCount` | `5` | Number of workspace indicators |
| `weatherLocation` | `"Munich"` | City name for wttr.in weather data |
| `useCelsius` | `true` | Temperature unit (`false` for Fahrenheit) |
| `use24h` | `true` | Clock format (`false` for 12-hour) |
| `weekStartsMonday` | `true` | Calendar week start day |
| `diskMount1` / `diskMount2` | `"/"` / `~/data` | Disk mounts shown in system popout |
| `idleProcess` | `"hypridle"` | Idle daemon to toggle |
| `lockCommand` | `"hyprlock"` | Lock screen command |

## Hyprland Layerrules (required for blur/transparency)

Add to your `hyprland.conf`:

```ini
# Enable blur on all Quickshell windows
layerrule = match:namespace quickshell:.*, blur on
layerrule = match:namespace quickshell:.*, ignore_alpha 0.79
```

The shell registers these namespaces:

| Namespace | Window |
|-----------|--------|
| `quickshell:bar` | The main bar panel |
| `quickshell:popout` | Popout overlay (notifications, media, weather, etc.) |
| `quickshell:osd` | Volume/brightness OSD |
| `quickshell:notifications` | Toast notification popups |
| `quickshell:idle` | Idle screen overlay |

To target specific windows, replace `quickshell:.*` with the exact namespace:

```ini
# Only blur the bar, not popouts
layerrule = match:namespace quickshell:bar, blur on
layerrule = match:namespace quickshell:bar, ignore_alpha 0.79
```

If you set `transparency: false` in Config.qml, layerrules are not needed.

## Dependencies

- **Hyprland** — compositor
- **PipeWire** — audio control
- **lm_sensors** (`sensors`) — CPU temperature
- **Nerd Fonts** (Inconsolata Go Nerd Font) — all icons
- **hyprlock** / **hypridle** / **hyprshutdown** — lock, idle, power
- **brightnessctl** — brightness OSD (optional, auto-detected)
- **wf-recorder** — screen recording (optional)
- **hyprpicker** — color picker (optional)
