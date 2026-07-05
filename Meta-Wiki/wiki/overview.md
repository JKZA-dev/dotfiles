# Overview — Fedora Dotfiles

**Summary:** A complete, automated Fedora setup that turns a fresh machine into a
fully configured workstation or server with a single command, driven by Ansible.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`README.md`)
**Related:** [[bootstrap-installation]], [[ansible-architecture]], [[desktop-vs-server]]
**Last updated:** 2026-06-21

---

## What it is

The repo (`JKZA-dev/dotfiles`) is the author's entire Fedora environment as code.
The promise: **"Ein Befehl, fertig eingerichteter PC"** — one command, a finished PC.
It installs system packages, sets up the shell, links all config files, copies SSH
files, and (on desktops) restores the KDE Plasma look and wallpapers.

## Two target profiles

The setup runs in one of two modes, chosen interactively at bootstrap:

- **Desktop (KDE)** — everything: base + GUI packages, wallpapers, KDE profile.
- **Server** — terminal only: base packages, ZSH, dotfiles, SSH. No GUI.

See [[desktop-vs-server]] for the full capability matrix.

## How the pieces fit

1. [[bootstrap-installation]] — `run-ansible.sh` is the entry point; it installs
   Git + Ansible, clones the repo, and launches the playbook.
2. [[ansible-architecture]] — `ansible/setup.yml` orchestrates six roles, gated by mode.
3. Roles configure the system: [[role-packages]], [[role-dotfiles-stow]],
   [[role-ssh]], [[role-kde-desktop]], plus ZSH-as-default-shell.
4. The actual configs live in stow packages: [[zsh-configuration]],
   [[neovim-configuration]], [[fastfetch-configuration]].
5. [[testing-molecule]] + [[ci-github-actions]] verify the whole thing in containers.

## Repo structure

```
~/dotfiles/
├── run-ansible.sh        ← entry point (asks Desktop/Server)
├── ansible/              ← setup.yml, inventory, roles/
├── zsh/                  ← ZSH dotfiles (stow package, bundles Oh-My-Zsh + p10k)
├── nvim/                 ← Neovim config (stow package)
├── fastfetch/            ← Fastfetch config (stow package)
├── ssh/                  ← SSH public key + known_hosts
├── konsave/              ← KDE Plasma profile (.knsv)
├── Backgrounds/          ← Hacknet wallpapers
├── molecule/             ← Molecule test scenarios
└── .github/workflows/    ← CI
```

## Conventions worth knowing

- **Comments are in German**, often informal/jokey. The code is idiomatic Ansible.
- The repo is **public**, so CI minutes are free (see [[ci-github-actions]]).
- Secrets (SSH private key) are never committed — see [[role-ssh]].
