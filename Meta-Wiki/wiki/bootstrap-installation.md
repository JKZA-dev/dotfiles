# Bootstrap & Installation

**Summary:** `run-ansible.sh` is the single entry point: it picks Desktop/Server,
installs Git + Ansible, clones the repo, installs collections, and runs the playbook.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`run-ansible.sh`, `README.md`, `deps.sh.alt`)
**Related:** [[overview]], [[ansible-architecture]], [[desktop-vs-server]], [[role-ssh]]
**Last updated:** 2026-06-21

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
2. **Install Git** if missing (`sudo dnf install -y git`).
3. **Install Ansible** if missing (`sudo dnf install -y ansible`).
4. **Clone the repo** to `$HOME/dotfiles` (skips if already present).
5. **Install Ansible collections** from `ansible/requirements.yml`
   (`ansible-galaxy collection install`).
6. **Run the playbook:**
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/setup.yml \
       --extra-vars "install_mode=${INSTALL_MODE}" --ask-become-pass
   ```
   The chosen mode is passed through as the `install_mode` extra-var — this is the
   single switch that drives all the desktop-vs-server gating in
   [[ansible-architecture]].

The script uses colored `info`/`erfolg`/`fehler` helpers and aborts (`exit 1`) on
any failed step.

## Post-install manual steps

The script and the SSH role both remind you:

1. Transfer/generate the **SSH private key** (`~/.ssh/id_ed25519`), then
   `chmod 600 ~/.ssh/id_ed25519` — the private key is intentionally not in the repo
   ([[role-ssh]]).
2. **Log out / back in** so ZSH (and on desktop, the KDE profile) takes effect.
3. (Desktop) The KDE profile apply is prompted during setup ([[role-kde-desktop]]).

## `deps.sh.alt` — legacy bootstrap

A superseded shell script that installed Oh-My-Zsh, the Spaceship prompt, and the
`zsh-syntax-highlighting` / `zsh-autosuggestions` plugins via `git clone`. It is
**no longer the path used** — Oh-My-Zsh and Powerlevel10k are now vendored in the
repo and linked by stow ([[role-dotfiles-stow]]), and the prompt is Powerlevel10k,
not Spaceship. Kept as `.alt` for reference only.
