# Ansible Architecture

**Summary:** `ansible/setup.yml` runs against localhost and orchestrates six roles;
the `install_mode` variable plus a `molecule_test` flag gate which roles run.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`ansible/setup.yml`, `inventory.ini`, `requirements.yml`)
**Related:** [[overview]], [[bootstrap-installation]], [[desktop-vs-server]], [[role-packages]], [[role-dotfiles-stow]], [[role-ssh]], [[role-kde-desktop]], [[zsh-configuration]]
**Last updated:** 2026-06-21

---

## Inventory — runs locally

`ansible/inventory.ini` targets only the local machine, no SSH:

```ini
[workstation]
localhost ansible_connection=local
```

## Main playbook — `ansible/setup.yml`

Runs on `hosts: all` with `become: false` by default (individual tasks escalate
with `become: true` only when they need root).

### Key variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `dotfiles_dir` | `$HOME/dotfiles` | Repo location |
| `omz_dir` | `$HOME/.oh-my-zsh` | Oh-My-Zsh location |
| `local_user` | `$USER` | Whose shell to change |
| `install_mode` | `desktop` (default) | Desktop vs server switch |

### Role order and gating

```yaml
roles:
  - { role: packages,    tags: packages }   # both modes
  - { role: zsh,         tags: zsh }         # both modes
  - { role: dotfiles,    tags: dotfiles }    # both modes
  - { role: ssh_config,  tags: ssh }         # both modes
  - { role: backgrounds, tags: backgrounds,
      when: install_mode == 'desktop' and not molecule_test | default(false) }
  - { role: kde,         tags: kde,
      when: install_mode == 'desktop' and not molecule_test | default(false) }
```

Two gating conditions:
- **`install_mode == 'desktop'`** — backgrounds and KDE only on desktops.
- **`not molecule_test`** — these two roles are *also* skipped inside containers,
  because KDE uses interactive `pause` tasks and needs a real Plasma session
  ([[testing-molecule]] sets `molecule_test: true`).

### Tags

Every role has a tag, so individual parts can be run standalone:
```bash
ansible-playbook -i ansible/inventory.ini ansible/setup.yml --tags packages \
    --extra-vars "install_mode=desktop" --ask-become-pass
ansible-playbook -i ansible/inventory.ini ansible/setup.yml --tags dotfiles   # no sudo
```

## Collections — `ansible/requirements.yml`

```yaml
collections:
  - name: community.general
```

`community.general` provides the `flatpak` and `flatpak_remote` modules used by
[[role-packages]]. Installed by the bootstrap via `ansible-galaxy collection install`.

## The zsh role (inline)

The `zsh` role itself is tiny — it only sets ZSH as the default shell:
```yaml
- name: "ZSH als Standard-Shell setzen"
  become: true
  ansible.builtin.user:
    name: "{{ local_user }}"
    shell: /bin/zsh
```
All the actual Oh-My-Zsh / Powerlevel10k / plugin content is vendored in the repo
and linked by [[role-dotfiles-stow]]. The user-facing shell config is documented in
[[zsh-configuration]].
