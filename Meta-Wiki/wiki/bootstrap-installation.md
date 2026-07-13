# Bootstrap & Installation

**Summary:** `run-ansible.sh` is the single entry point: it picks Desktop/Server,
optionally opts into Gaming-Ready packages, optionally generates an SSH key and
switches the remote to SSH, installs Git + Ansible, clones the repo, installs
collections, and runs the playbook.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`run-ansible.sh`, `README.md`, `deps.sh.alt`)
**Related:** [[overview]], [[ansible-architecture]], [[desktop-vs-server]], [[role-ssh]], [[role-packages]]
**Last updated:** 2026-07-13

---

## One-command install

**Locally on the new machine:**
```bash
curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash
```

**Over SSH from another machine:**
```bash
ssh benutzer@neuer-pc 'curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash'
```

## What `run-ansible.sh` does, step by step

1. **Prompt for mode** — interactive `1) Desktop` / `2) Server`, reading from
   `/dev/tty` (so it works even when the script is piped from `curl`). Sets
   `INSTALL_MODE` to `desktop` or `server`.
2. **Gaming-Ready decision (desktop only)** — asks `[j/n]` whether to additionally
   install Steam (package) and Prism Launcher (Flatpak). Stores the choice in
   `GAME_READY` (defaults `false`; the question is skipped entirely in server mode).
   See [[role-packages]].
3. **SSH-Key decision** — checks if `~/.ssh/id_ed25519` already exists (warns before
   overwriting), then asks `[j/n]` whether to generate a new ed25519 key. Stores the
   choice in `GEN_SSH_KEY`; the key is not generated yet, just deferred.
4. **HTTPS → SSH remote decision** — asks whether to switch the cloned dotfiles repo
   from HTTPS to SSH (for contributing). Stores the choice in `CHANGE_TO_SSH`.
   All three decisions are collected upfront before any automated steps run.
5. **Install Git** if missing (`sudo dnf install -y git`).
6. **Install Ansible** if missing (`sudo dnf install -y ansible`).
7. **Clone the repo** to `$HOME/dotfiles` (skips if already present).
8. **Install Ansible collections** from `ansible/requirements.yml`
   (`ansible-galaxy collection install`).
9. **Run the playbook:**
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/setup.yml \
       --extra-vars "install_mode=${INSTALL_MODE} game_ready=${GAME_READY}" \
       --ask-become-pass
   ```
   The chosen mode/flag are passed through as the `install_mode` and `game_ready`
   extra-vars — these are the switches that drive the desktop-vs-server and
   Gaming-Ready gating in [[ansible-architecture]] and [[role-packages]].
10. **SSH-Key generation** — if `GEN_SSH_KEY=true`, calls
    `ansible/roles/ssh_config/tasks/generate_ssh_key.sh` interactively
    (see [[role-ssh]]).
11. **HTTPS → SSH migration** — if `CHANGE_TO_SSH=true`:
    - If no key exists at this point: offers a second chance to generate one via
      `generate_ssh_key.sh`.
    - If a key is present: prints the public key (`cat ~/.ssh/id_ed25519.pub`),
      pauses for the user to add it to GitHub (`github.com/settings/keys`), then
      executes `git remote set-url origin git@github.com:JKZA-dev/dotfiles.git`
      and verifies with `git remote -v`.

The script uses colored `info`/`erfolg`/`fehler` helpers and aborts (`exit 1`) on
any failed step.

## Post-install manual steps

1. **Log out / back in** so ZSH (and on desktop, the KDE profile) takes effect.
2. (Desktop) The KDE profile apply is prompted during setup ([[role-kde-desktop]]).

## `deps.sh.alt` — legacy bootstrap

A superseded shell script that installed Oh-My-Zsh, the Spaceship prompt, and the
`zsh-syntax-highlighting` / `zsh-autosuggestions` plugins via `git clone`. It is
**no longer the path used** — Oh-My-Zsh and Powerlevel10k are now vendored in the
repo and linked by stow ([[role-dotfiles-stow]]), and the prompt is Powerlevel10k,
not Spaceship. Kept as `.alt` for reference only.
