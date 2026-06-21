# Testing with Molecule

**Summary:** Molecule tests the playbook in Fedora/Podman containers across `desktop`
and `server` scenarios, running create → converge → idempotency → verify → destroy.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`TESTING.md`, `molecule/**`, `requirements.txt`)
**Related:** [[ansible-architecture]], [[ci-github-actions]], [[role-packages]], [[role-dotfiles-stow]], [[role-ssh]], [[desktop-vs-server]]
**Last updated:** 2026-06-21

---

## What & why

Molecule is a test framework for Ansible. It spins up a throwaway container, runs the
playbook, re-runs it to check idempotency, asserts the result, and tears down — so
bugs surface in an isolated container instead of on a real machine, and PRs get
automatic pass/fail ([[ci-github-actions]]).

## Requirements (`requirements.txt`)

```
ansible>=9.0.0
molecule>=24.0.0
molecule-plugins[podman]>=23.5.0
```
Plus Python 3.10+ and Podman. `pip install -r requirements.txt` (venv recommended).

## Test cycle

`molecule test` runs: dependency → create → (prepare unused) → converge →
**idempotency** (second converge must report 0 changed) → verify → destroy.

Common commands:
```bash
molecule test              # default = desktop
molecule test -s desktop
molecule test -s server
molecule converge -s desktop   # run playbook, keep container
molecule login -s desktop      # shell into container
molecule destroy -s desktop
molecule converge -s desktop -- --tags packages   # pass-through args
```

## Scenario layout

```
molecule/
├── default/   # base config (desktop); converge.yml + verify.yml live here
├── desktop/   # install_mode: desktop  (reuses ../default playbooks)
└── server/    # install_mode: server   (reuses ../default playbooks)
```

All three share `molecule/default/converge.yml` and `verify.yml`; `desktop` and
`server` only differ in the `install_mode` group_var. (TESTING.md describes the older
symlink arrangement; the current `desktop`/`server` `molecule.yml` instead point at
the default playbooks via the `playbooks:` provisioner key.)

### molecule.yml essentials (all scenarios)

- **driver:** podman; **platform:** `quay.io/fedora/fedora:latest`, privileged,
  `SYS_ADMIN` capability.
- **group_vars/all:** `install_mode: desktop|server` **and `molecule_test: true`** —
  the latter is what makes [[ansible-architecture]] skip the `kde` and `backgrounds`
  roles (no Plasma session / interactive pauses in a container).

### converge.yml — container prep

Before importing `ansible/setup.yml`, a prep play installs `python3` + `sudo` via
`raw`, and copies the `zsh`, `nvim`, `fastfetch`, `ssh`, `Backgrounds` folders into
`/root/dotfiles/` (the container has no git clone).

## What verify.yml asserts

Runs as root in the container. Checks:
1. Base packages present (zsh, neovim, btop, fastfetch, git, stow).
2. `/bin/zsh` exists and is root's default shell.
3. Dotfiles symlinks exist **and are symlinks**: `.zshrc`, `.config/nvim`,
   `.config/fastfetch` ([[role-dotfiles-stow]]).
4. `~/.ssh` exists, dir, mode `0700`; `known_hosts` present ([[role-ssh]]).
5. **Desktop only:** `gimp` + `kicad` installed, `~/Pictures/Hacknet` exists.
6. **Server only:** `gimp`, `kicad`, `plasma-browser-integration` **not** installed.

## Common failure modes (from TESTING.md)

- Podman socket `permission denied` → `systemctl --user start podman.socket` or run
  with root podman.
- `image not known` → `podman pull quay.io/fedora/fedora:latest`.
- `No module named 'libdnf5'` → container must be Fedora 41+ (dnf5).
- Idempotency fail (`changed > 0` on 2nd run) → fix the offending task to be idempotent.
- Stow `existing target...` → a real file blocks a symlink; remove and restow.
