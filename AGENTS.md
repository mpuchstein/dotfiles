# Repository Guidelines

## Project Structure & Module Organization
This is a chezmoi dotfiles source tree. Key paths:
- `dot_config/` maps to `~/.config/` (e.g., `dot_config/hypr/`, `dot_config/nvim/`, `dot_config/waybar/`).
- `dot_local/` maps to `~/.local/` (app data, scripts, etc.).
- `dot_profile.tmpl` renders to `~/.profile`.
- `.chezmoiscripts/` contains chezmoi hooks (e.g., `run_onchange_*` scripts).
- Host-specific variants use `##hostname.<name>` (e.g., `hyprpaper.conf##hostname.owlenlap01`).
- `dot_config/waybar/waybar.wiki/` and `dot_config/hypr/hyprland.wiki/` are mirrored docs with `dot_git/` metadata; treat them as upstream mirrors unless intentionally updating.

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
