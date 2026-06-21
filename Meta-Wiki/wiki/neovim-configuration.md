# Neovim Configuration

**Summary:** Neovim runs a near-stock LazyVim setup; `init.lua` bootstraps lazy.nvim,
and the per-user config/keymap/option files are left as empty LazyVim stubs.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`nvim/.config/nvim/init.lua`, `lua/config/lazy.lua`, `options.lua`, `keymaps.lua`, `lazyvim.json`)
**Related:** [[role-dotfiles-stow]], [[zsh-configuration]]
**Last updated:** 2026-06-21

---

## Stack

- **LazyVim** distribution on top of **lazy.nvim** plugin manager.
- Stowed as the `nvim` package → `~/.config/nvim/` ([[role-dotfiles-stow]]).
- Launched via the `v` alias and set as `$EDITOR` ([[zsh-configuration]]).

## Bootstrap chain

`init.lua` → `require("config.lazy")`. `lua/config/lazy.lua`:
- Clones `lazy.nvim` (stable branch) into `stdpath("data")` if missing.
- Loads LazyVim plugins + a local `plugins` spec, `lazy = false` for custom plugins.
- `install.colorscheme = { "tokyonight", "habamax" }`.
- `checker.enabled = true` (periodic update checks, no notify).
- Disables some built-in rtp plugins (gzip, tarPlugin, tohtml, tutor, zipPlugin).

## Customization state

Essentially **vanilla LazyVim** — the user-extension files are still the default
stubs:
- `lua/config/options.lua` — empty (comment only).
- `lua/config/keymaps.lua` — empty (comment only).
- `lua/plugins/example.lua` — the LazyVim example file.
- `lazyvim.json` — no `extras` enabled, `install_version: 8`.
- `lazy-lock.json` — generated plugin lockfile (not distilled; treat as machine state).

To extend: add options to `options.lua`, keymaps to `keymaps.lua`, plugin specs under
`lua/plugins/`, or enable LazyVim extras in `lazyvim.json`.
