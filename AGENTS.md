# Repository Guidelines

## Project Structure & Module Organization
This is a chezmoi dotfiles source tree. Key paths:
- `dot_config/` maps to `~/.config/` (e.g., `dot_config/hypr/`, `dot_config/nvim/`, `dot_config/waybar/`).
- `dot_local/` maps to `~/.local/` (app data, scripts, etc.).
- `dot_profile.tmpl` renders to `~/.profile`.
- `.chezmoiscripts/` contains chezmoi hooks (e.g., `run_onchange_*` scripts).
- Host-specific variants use `##hostname.<name>` (e.g., `hyprpaper.conf##hostname.owlenlap01`).

## Documentation
- Docs live under `dot_local/share/docs/` as git submodules and use the `external_` attribute so chezmoi does not interpret their contents.
- `dot_local/share/docs/external_chezmoi-docs` (sparse checkout `assets/chezmoi.io`) renders to `~/.local/share/docs/chezmoi-docs`.
- `dot_local/share/docs/external_hyprland.wiki` (sparse checkout `content`) renders to `~/.local/share/docs/hyprland.wiki`.
- `dot_local/share/docs/external_waybar.wiki` renders to `~/.local/share/docs/waybar.wiki`.
- Waybar manual pages are not stored in the repo; use `man 5 waybar` and `man 5 waybar-<module>` for module docs.

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
There is no build system; apply and verify changes with chezmoi:
- `chezmoi diff` preview pending changes.
- `chezmoi apply` render and apply to `$HOME`.
- `chezmoi status` show managed file status.
After applying, restart the affected app (e.g., reload Hyprland/Waybar) to validate.

## Coding Style & Naming Conventions
- Match the existing file’s formatting; don’t reflow unrelated sections.
- Lua configs in `dot_config/nvim/` use 2‑space indents and include `dot_config/nvim/dot_stylua.toml` and `dot_config/nvim/selene.toml` for format/lint settings.
- Use chezmoi prefixes: `dot_` for dotfiles, `executable_` for executable files, `symlink_` for symlinks, `private_` for restricted‑permission files, and `.tmpl` for Go templates.

## Testing Guidelines
No automated tests are defined. Validate by:
- Running `chezmoi diff` and `chezmoi apply`.
- Smoke‑testing the specific tool you changed (e.g., open Neovim, restart Waybar, reload Hyprland).

## Commit & Pull Request Guidelines
This repository has no commits yet, so there is no established commit message convention. Use short, imperative subjects and include a scope when helpful (e.g., `hypr: adjust keybinds`). For PRs, include a clear summary, affected paths, and screenshots for visual/UI changes.
