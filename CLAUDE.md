# CLAUDE.md — chezmoi dotfiles

Chezmoi source tree for a Linux desktop (Hyprland + Neovim + Zsh/Zim).

## Commands

```bash
chezmoi diff          # preview pending changes
chezmoi apply         # render templates and apply to $HOME
chezmoi status        # show managed file status
```

After applying, reload the affected tool:
- Hyprland: `hyprctl reload`
- Waybar: `pkill waybar && waybar &`
- Neovim: reopen or `:source`
- Zsh: `exec zsh`

## Chezmoi file naming

| Prefix/Suffix | Meaning |
|---|---|
| `dot_` | maps to `.` (e.g. `dot_config/` → `~/.config/`) |
| `executable_` | sets executable bit |
| `private_` | restricts permissions (600/700) |
| `symlink_` | creates a symlink |
| `.tmpl` | Go template rendered at apply time |
| `##hostname.<name>` | host-specific variant |

## Template data (`chezmoi.toml`)

Config lives at `~/.config/chezmoi/chezmoi.toml` (not tracked). Access tags via `.chezmoi.config.data.tags.<tag>`.

Current tags: `desktop`, `laptop`, `hyprland`, `waybar`, `pipewire`, `dev`, `entertainment`, `cs2`, `bluetooth`

- `microphone` is only present when `pipewire = true` — guard with `{{- if (index $tags "pipewire") }}`.
- `data.monitors` is an array; number of entries varies by machine.

## Architecture

- **`dot_config/hypr/`** — Hyprland. Entry point: `hyprland.conf`. Modular includes in `hyprland.d/`. New settings go in the appropriate `hyprland.d/` file.
- **`dot_config/nvim/`** — Neovim (Lua + lazy.nvim). `init.lua` bootstraps lazy. Plugins: `lazy_setup.lua`. General settings: `polish.lua`. 2-space indents; see `dot_stylua.toml` + `selene.toml`.
- **`dot_config/waybar/`** — Waybar config and styles. Host-specific variants via `##hostname.<name>`.
- **`dot_config/zsh/`** — Zsh + Zim + Powerlevel10k. Aliases: `aliases.zsh`.
- **`dot_local/bin/`** — User scripts (all `executable_` prefixed).
- **`.chezmoiscripts/`** — `run_onchange_*` hooks run on `chezmoi apply`.

## Theming — apex-aeon / apex-neon

Two custom themes (`apex-aeon` dark, `apex-neon` neon) are applied across nvim, zsh, waybar, alacritty, kitty, ghostty, btop, fuzzel, gtk4, spicetify, swaync, wezterm, zathura, zed.

Theme files are **not edited by hand** — they are synced from `~/Dev/Themes/apex/dist` using:

```bash
refresh-apex-themes
```

This copies built theme artifacts into the appropriate `dot_config/*/themes/` directories.

## Local documentation

| Topic | Path |
|---|---|
| chezmoi | `~/.local/share/docs/chezmoi-docs/` |
| Hyprland | `~/.local/share/docs/hyprland.wiki/` |
| Waybar | `~/.local/share/docs/waybar.wiki/` (also `man 5 waybar`) |
| Ghostty | `/usr/share/ghostty` |

## Commit convention

```
scope: imperative subject
```

Examples: `hypr: adjust keybinds`, `waybar: tweak clock format`, `nvim: add plugin`

For visual/UI changes include screenshots in the PR description, along with affected paths.
