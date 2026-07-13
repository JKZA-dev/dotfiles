# Meta-Wiki Index

Master index of all wiki pages and their relationships.
Last updated: 2026-07-13

---

## Pages

### Start here
- [Overview — Fedora Dotfiles](wiki/overview.md) — what the repo is and how the pieces fit | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Bootstrap & Installation](wiki/bootstrap-installation.md) — `run-ansible.sh` one-command install flow incl. Gaming-Ready, SSH-Key & remote-migration steps | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-07-13
- [Desktop vs Server Modes](wiki/desktop-vs-server.md) — the `install_mode` switch, capability matrix, and the orthogonal Gaming-Ready opt-in | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-07-13

### Ansible
- [Ansible Architecture](wiki/ansible-architecture.md) — setup.yml, inventory, role gating, collections, `game_ready` var | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-07-13
- [Role: packages](wiki/role-packages.md) — base + desktop packages (incl. `jq`), Gaming-Ready (Steam/Prism Launcher), Edge, Flatpak app list, pip tools | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-07-13
- [Role: dotfiles (Stow)](wiki/role-dotfiles-stow.md) — GNU Stow symlinking of zsh/nvim/fastfetch (`--verbose`-based idempotency) | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-07-13
- [Role: ssh_config](wiki/role-ssh.md) — `~/.ssh` perms, known_hosts, key security model + `generate_ssh_key.sh` & `HowToChangeOrigin.txt` | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-06-25
- [Role: kde & backgrounds](wiki/role-kde-desktop.md) — Konsave KDE profile + wallpapers (desktop only) | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21

### Application configs (stow packages)
- [ZSH Configuration](wiki/zsh-configuration.md) — Oh-My-Zsh, Powerlevel10k, aliases, startup banner now driven by `hostnamectl`/`jq` | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-07-13
- [Neovim Configuration](wiki/neovim-configuration.md) — LazyVim / lazy.nvim (near-stock) | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21
- [Fastfetch Configuration](wiki/fastfetch-configuration.md) — module list + custom OS_Age module | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | ingested: 2026-06-21

### Quality
- [Testing with Molecule](wiki/testing-molecule.md) — Podman scenarios, prepare stage, verify checks, failure modes | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-06-29
- [CI — GitHub Actions](wiki/ci-github-actions.md) — two-tier lint + desktop/server molecule matrix | source: `raw/2026-06-21-dotfiles-repo-snapshot.md` | updated: 2026-06-29

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
- `testing-molecule` → `ansible-architecture` (`molecule_test` flag gates kde + heavy packages)
- `testing-molecule` verifies → `role-packages`, `role-dotfiles-stow`, `role-ssh`, `desktop-vs-server`
- `ci-github-actions` → `testing-molecule` (CI's `lint` job gates the Molecule matrix)

---

## Statistics

| Metric | Count |
|--------|-------|
| Total pages | 13 |
| Total sources | 1 |
| Last ingest | 2026-06-21 |
| Last update | 2026-07-13 |
