# dotfiles

[![CI](https://github.com/JKZA-dev/dotfiles/actions/workflows/test-ansible.yml/badge.svg)](https://github.com/JKZA-dev/dotfiles/actions/workflows/test-ansible.yml)

One command turns a fresh Fedora or macOS machine into my workstation or server.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash
```

Over SSH (a TTY is required):

```bash
ssh -t user@host 'curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash'
```

The script asks for the mode, gaming packages, the KDE profile, SSH key generation and the Git remote, then runs the playbook. Set `DOTFILES_DIR` to clone somewhere other than `~/dotfiles`.

## What gets installed

| | Fedora | macOS |
|---|---|---|
| **Server + Desktop** | zsh stack, Neovim with toolchain, CLI tools, SSH known hosts, RPM Fusion | zsh stack, Neovim with toolchain, CLI tools, SSH known hosts |
| **Desktop** | Zen, GIMP, KiCad, Element, Discord, Whatsie, Flatseal, Java, JetBrains Mono Nerd Font, wallpapers, KDE profile, fastfetch splash | Zen, GIMP, KiCad, Element, Discord, WhatsApp, Java, JetBrains Mono Nerd Font, wallpapers, Terminal profile |
| **Gaming** (Desktop only) | Steam, Prism Launcher | Steam, Prism Launcher |

Package lists: [`vars/Fedora.yml`](ansible/roles/packages/vars/Fedora.yml), [`vars/MacOSX.yml`](ansible/roles/packages/vars/MacOSX.yml).

## Partial runs

```bash
cd ansible
ansible-playbook setup.yml --tags dotfiles
ansible-playbook setup.yml --ask-become-pass --tags packages -e '{"install_mode":"server","gaming":false}'
```

Tags match the role names: `packages`, `shell`, `dotfiles`, `neovim`, `ssh`, `kde`, `macos`.

## Layout

| Path | Purpose |
|---|---|
| `run-ansible.sh` | Bootstrap |
| `ansible/` | Playbook and roles |
| `stow/` | Packages linked into `$HOME` |
| `vendor/` | Pinned Git submodules, never edited |
| `kde/profile/` | Unpacked konsave profile; update with `scripts/kde-export.sh` |
| `macos/` | Terminal profile |
| `molecule/`, `.config/molecule/` | Container tests, see [TESTING.md](TESTING.md) |
| `Meta-Wiki/` | Detailed docs, start at [the index](Meta-Wiki/index.md) |

Wallpapers use Git LFS, so `git-lfs` must be installed before cloning by hand. Clone with `--recurse-submodules`.
