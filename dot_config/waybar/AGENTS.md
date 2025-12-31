# Repository Guidelines

## Project Structure & Module Organization
This is a chezmoi dotfiles source tree scoped to Waybar. The current directory maps to `~/.config/waybar/` on apply.
- `dot_config/waybar/` contains Waybar config, style, and module files.
- Host-specific variants use `##hostname.<name>` suffixes (e.g., `config##hostname.laptop`).

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
There is no build system. Use chezmoi to preview and apply changes:
- `chezmoi diff` preview pending changes.
- `chezmoi apply` render and apply files to `$HOME`.
- `chezmoi status` show managed file status.
After applying, restart Waybar to validate changes.

## Coding Style & Naming Conventions
- Match existing file formatting; avoid reflowing unrelated sections.
- Prefer ASCII unless the file already uses Unicode.
- Use chezmoi naming conventions: `dot_` for dotfiles, `executable_` for executables, `private_` for restricted files, `.tmpl` for Go templates, `symlink_` for symlinks.
- Keep module names descriptive and aligned with Waybar’s config keys.

## Testing Guidelines
No automated tests are defined. Validate by:
- Running `chezmoi diff` and `chezmoi apply`.
- Smoke-testing Waybar (reload or restart) to confirm layout and modules.

## Commit & Pull Request Guidelines
The repository has no established Git history. Use short, imperative commit subjects and include a scope when helpful (e.g., `waybar: tweak clock format`). For pull requests, include:
- A concise summary of changes.
- Affected paths (e.g., `dot_config/waybar/config`).
- Screenshots for visual/UI changes.

## Notes for Contributors
Avoid editing unrelated dotfiles unless requested. If you touch mirrored docs or host-specific files, call it out explicitly in your summary.
