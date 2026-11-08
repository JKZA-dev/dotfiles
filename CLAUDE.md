# CLAUDE.md

Ansible-based dotfiles for Fedora and macOS. `run-ansible.sh` bootstraps a machine.

Detailed docs: read `Meta-Wiki/index.md` first, then the linked `Meta-Wiki/wiki/*.md` pages.

## Entry points
| Path | Purpose |
|---|---|
| `run-ansible.sh` | Interactive bootstrap |
| `ansible/setup.yml` | Main playbook |
| `ansible/roles/packages/vars/` | Package matrix per OS |
| `stow/` | Packages linked into `$HOME` |
| `vendor/` | Pinned submodules; never edit |
| `kde/profile/` | Unpacked konsave profile |
| `molecule/`, `.config/molecule/` | Container tests |

## Roles
`packages` · `shell` · `dotfiles` · `neovim` · `ssh` · `kde` (Fedora desktop) · `macos` (macOS desktop)

## Conventions
- `install_mode: desktop|server` and `gaming: true|false` select package groups once, in `packages/tasks/main.yml`.
- OS differences live in `vars/<distribution>.yml` and `tasks/<distribution>.yml`, using identical keys.
- Test exclusions are feature toggles (`packages_heavy`, `packages_flatpak`, `neovim_bootstrap`).
- Always `stow --no-folding`: directory symlinks would let apps write into the repo.
- Own configuration goes in `stow/` or role variables, never in `vendor/`.
- Comments explain why, in English, in one line where possible.
