# Bootstrap

`run-ansible.sh` is interactive and needs a TTY; over SSH use `ssh -t`. It aborts immediately without one.

## Order
1. Questions: mode, gaming and KDE profile (desktop), SSH key, Git remote.
2. Prerequisites: `dnf install git git-lfs ansible` on Fedora. On macOS, Homebrew if missing, then `brew install git git-lfs ansible`.
3. Repo: clone with `--recurse-submodules`, or `pull --ff-only` and `submodule update --init`.
4. `ansible-galaxy collection install`, then `ansible-playbook setup.yml --ask-become-pass`. Answers are passed as JSON extra vars so booleans stay booleans.
5. Optional: `generate_ssh_key`, then `switch_remote_to_ssh`, see [[role-ssh]].

`DOTFILES_DIR` overrides the default `~/dotfiles`.
