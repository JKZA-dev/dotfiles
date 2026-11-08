# Ansible architecture

`ansible/setup.yml` is one play listing the roles in order: `packages`, `shell`, `dotfiles`, `neovim`, `ssh`, `kde`, `macos`. Each has a tag of the same name. Run from `ansible/` so `ansible.cfg` applies.

## Variables
| Variable | Default | Set by |
|---|---|---|
| `install_mode` | `desktop` | Bootstrap; validated in `packages/meta/argument_specs.yml` |
| `gaming` | `false` | Bootstrap |
| `dotfiles_dir` | `~/dotfiles` | Bootstrap |

Shared defaults live in `inventory/group_vars/all.yml`. Never define them as play `vars` or in `group_vars/` next to `setup.yml`: both override the values set by [[testing-molecule]].

Role options use the role name as a prefix and live in `defaults/main.yml`. Tests switch off expensive parts with feature toggles rather than a test flag.

Collections are pinned in `requirements.yml`.
