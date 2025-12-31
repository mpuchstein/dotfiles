# Repository Guidelines

## Project Structure & Module Organization
This directory is the Hyprland portion of a chezmoi dotfiles source tree. Key paths:
- `dot_config/` maps to `~/.config/` (e.g., `dot_config/hypr/`, `dot_config/nvim/`, `dot_config/waybar/`).
- `dot_local/` maps to `~/.local/` (scripts, data, and app state).
- `dot_profile.tmpl` renders to `~/.profile`.
- `.chezmoiscripts/` holds chezmoi hooks such as `run_onchange_*`.
- Host-specific variants use `##hostname.<name>` (e.g., `hyprpaper.conf##hostname.owlenlap01`).

Hyprland configuration lives here in `hyprland.conf`, with modular includes under `hyprland.d/` and related configs like `hypridle.conf`, `hyprlock.conf.tmpl`, and `hyprpaper.conf.tmpl`.

## Chezmoi Config (chezmoi.toml)
- Source of truth: `~/.config/chezmoi/chezmoi.toml` (not tracked here).
- Tag keys are stable across machines; templates must access them via `.chezmoi.config.data.tags.<tag>`.
- `microphone` is only present when `pipewire` is true; guard access with the tag.
- `data.monitors` is an array and the number of entries varies by machine.
- Reference structure (current machine):
  ```
  [data]
  tags = { desktop = true, laptop = false, hyprland = true, waybar = true, pipewire = true, dev = true, entertainment = true, cs2 = true, bluetooth = false }
  microphone = "alsa_input.usb-DCMT_Technology_USB_Condenser_Microphone_214b206000000178-00.mono-fallback"

  # --- Primary Monitor ---
  [[data.monitors]]
  name = "DP-1"
  primary = true
  width = 1920
  height = 1080
  refresh_rate = 60
  position = "0x0"
  scale = 1.0
  workspaces = [1, 2, 3, 4, 5]
  wallpaper = "/home/mpuchstein/Pictures/wallpaper/ki/1920x1080/rosepinesuccubus11.png"

  # --- Secondary Monitor ---
  [[data.monitors]]
  name = "DP-2"
  width = 1920
  height = 1080
  refresh_rate = 144
  position = "1920x0"
  scale = 1.0
  vrr = 1
  workspaces = [6, 7, 8, 9, 10]
  wallpaper = "/home/mpuchstein/Pictures/wallpaper/ki/1920x1080/witch_autumn.png"
  ```

## Build, Test, and Development Commands
There is no build system. Validate changes via chezmoi:
- `chezmoi diff` shows pending changes between source and target files.
- `chezmoi apply` renders templates and applies updates to `$HOME`.
- `chezmoi status` summarizes managed file state.

After applying, reload Hyprland (e.g., `hyprctl reload`) or restart related tools to verify behavior.

## Coding Style & Naming Conventions
- Match existing formatting; avoid reflowing unrelated blocks.
- Use chezmoi prefixes: `dot_` for dotfiles, `executable_` for executables, `symlink_` for symlinks, `private_` for restricted files, and `.tmpl` for Go templates.
- Keep templates minimal and use `##hostname.<name>` for host-specific variants.

## Testing Guidelines
No automated tests are defined. Validate by:
- Running `chezmoi diff` and `chezmoi apply`.
- Smoke-testing the affected tool (e.g., reload Hyprland, start Waybar).

## Commit & Pull Request Guidelines
No established Git history. Use concise, imperative commit subjects with optional scope (e.g., `hypr: adjust keybinds`). For PRs, include:
- A clear summary of changes.
- Affected paths (e.g., `dot_config/hypr/hyprland.conf`).
- Screenshots for visible UI changes.

## Agent-Specific Notes
