# Meta-Wiki Index

Master index of all wiki pages and their relationships.
Last updated: 2026-06-21

---

## Pages

### Start here
- [Overview — Fedora Dotfiles](wiki/overview.md) — what the repo is and how the pieces fit | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Bootstrap & Installation](wiki/bootstrap-installation.md) — `run-ansible.sh` one-command install flow | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Desktop vs Server Modes](wiki/desktop-vs-server.md) — the `install_mode` switch and capability matrix | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21

### Ansible
- [Ansible Architecture](wiki/ansible-architecture.md) — setup.yml, inventory, role gating, collections | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Role: packages](wiki/role-packages.md) — base + desktop packages, Edge, Flatpak, pip tools | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Role: dotfiles (Stow)](wiki/role-dotfiles-stow.md) — GNU Stow symlinking of zsh/nvim/fastfetch | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Role: ssh_config](wiki/role-ssh.md) — `~/.ssh` perms, known_hosts, key security model | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Role: kde & backgrounds](wiki/role-kde-desktop.md) — Konsave KDE profile + wallpapers (desktop only) | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21

### Application configs (stow packages)
- [ZSH Configuration](wiki/zsh-configuration.md) — Oh-My-Zsh, Powerlevel10k, aliases, startup banner | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Neovim Configuration](wiki/neovim-configuration.md) — LazyVim / lazy.nvim (near-stock) | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Fastfetch Configuration](wiki/fastfetch-configuration.md) — module list + custom OS_Age module | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21

### Quality
- [Testing with Molecule](wiki/testing-molecule.md) — Podman scenarios, verify checks, failure modes | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [CI — GitHub Actions](wiki/ci-github-actions.md) — parallel desktop/server matrix workflow | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21

---

## Topic Graph

Entry & orchestration:
- `overview` → everything (hub page)
- `bootstrap-installation` → `ansible-architecture` (script runs the playbook)
- `bootstrap-installation` → `desktop-vs-server` (script picks the mode)
- `ansible-architecture` → all six roles (orchestrates them)
- `desktop-vs-server` ↔ `ansible-architecture` (mode drives role/task gating)

Roles → configs:
- `ansible-architecture` → `zsh-configuration` (sets default shell; config is stowed)
- `role-dotfiles-stow` → `zsh-configuration`, `neovim-configuration`, `fastfetch-configuration` (links them into $HOME)
- `role-packages` → `zsh-configuration` (installs cmatrix/lolcat behind joke aliases)
- `role-packages` → `role-kde-desktop` (desktop GUI packages)
- `role-kde-desktop` → `fastfetch-configuration` (shared KDE splash mention)

Config cross-links:
- `zsh-configuration` → `fastfetch-configuration` (startup runs fastfetch)
- `zsh-configuration` → `neovim-configuration` (`v` alias, `$EDITOR`)
- `zsh-configuration` → `role-kde-desktop` (PATH exposes pip `--user` konsave)

Quality:
- `testing-molecule` → `ansible-architecture` (`molecule_test` flag gates roles)
- `testing-molecule` verifies → `role-packages`, `role-dotfiles-stow`, `role-ssh`, `desktop-vs-server`
- `ci-github-actions` → `testing-molecule` (CI runs Molecule scenarios)

---

## Statistics

| Metric | Count |
|--------|-------|
| Total pages | 13 |
| Total sources | 1 |
| Last ingest | 2026-06-21 |
