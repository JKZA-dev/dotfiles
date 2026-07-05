# CLAUDE.md — Fedora Dotfiles Repo

## What this repo is
Ansible-based dotfiles + system configuration for Fedora. One command (`run-ansible.sh`) bootstraps a fresh machine. Supports two modes: `desktop` (full KDE setup) and `server` (headless).

## Meta-Wiki
Detailed knowledge lives in `Meta-Wiki/` — read `Meta-Wiki/index.md` first to navigate it. The wiki covers architecture, roles, testing, CI, and config details. Use it instead of re-deriving context from the raw files.

**Query pattern:** Read `Meta-Wiki/index.md` → follow links to relevant `Meta-Wiki/wiki/*.md` pages.

## Key entry points
| File/Dir | Purpose |
|---|---|
| `run-ansible.sh` | Bootstrap script — SSH keygen, remote migration, runs playbook |
| `ansible/setup.yml` | Main playbook |
| `ansible/inventory` | Target hosts |
| `molecule/` | Molecule test scenarios (Podman) |
| `.github/workflows/` | CI: lint job gates molecule matrix |

## Roles
`packages` · `dotfiles` (GNU Stow) · `ssh_config` · `kde` · `backgrounds` · `zsh`

## Conventions
- `install_mode: desktop|server` gates desktop-only tasks
- `molecule_test: true` gates heavy packages/GUI tasks out of CI containers
- Stow packages: `zsh/`, `nvim/`, `fastfetch/` → symlinked into `$HOME`
- `--break-system-packages` used for pip (PEP 668, Fedora)
