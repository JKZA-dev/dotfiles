# Raw Source — dotfiles repository snapshot

**Type:** Repository self-ingest
**Repo:** JKZA-dev/dotfiles
**Branch:** JKZA-dev/issue8
**Commit:** 5e8cb3c (add fastfetch splashscreen)
**Captured:** 2026-06-21

## What this source is

This is not an external document but the dotfiles repository itself, ingested
into its own Meta-Wiki. The ground truth lives in the repo files; this note
records the provenance of the ingest so wiki pages can cite a stable source.

## Files read during ingest

Project-owned configuration and docs (vendored third-party trees were
deliberately excluded — see exclusions below):

- `README.md`, `TESTING.md`
- `run-ansible.sh`, `deps.sh.alt` (legacy)
- `requirements.txt`
- `ansible/setup.yml`, `ansible/inventory.ini`, `ansible/requirements.yml`
- `ansible/roles/{packages,zsh,dotfiles,ssh_config,backgrounds,kde}/tasks/main.yml`
- `molecule/{default,desktop,server}/molecule.yml`
- `molecule/default/{converge.yml,verify.yml}`
- `.github/workflows/test-ansible.yml`, `.github/workflows/.env.example`
- `zsh/.zshrc`, `zsh/.oh-my-zsh/custom/{aliases.zsh,startupcode.zsh,Device.txt}`
- `nvim/.config/nvim/{init.lua,lazyvim.json,lua/config/lazy.lua,options.lua,keymaps.lua}`
- `fastfetch/.config/fastfetch/config.jsonc`
- `fastfetch-Splashscreen/fastfetch-splash/metadata.json`

## Exclusions (vendored / generated — not distilled)

- `zsh/.oh-my-zsh/**` except `custom/` — full Oh-My-Zsh distribution (plugins, lib, themes)
- `zsh/.oh-my-zsh/custom/themes/powerlevel10k/**` — vendored Powerlevel10k theme + gitstatus C++ source
- `Backgrounds/**` — binary wallpaper images (Hacknet set)
- `konsave/JKZA-KDE-Workstation.knsv` — binary KDE profile archive
- `fastfetch-Splashscreen/fastfetch-splash/**` source — third-party Plasma splash (MIT, by herzane)
- `nvim/.config/nvim/lazy-lock.json` — generated plugin lockfile
- `ssh/.ssh/{id_ed25519.pub,known_hosts}` — key material / host records
