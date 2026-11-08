# Role: ssh

Creates `~/.ssh` with mode `0700` and adds each line of `roles/ssh/files/known_hosts` through the `known_hosts` module. Host keys learned later are preserved.

Private keys never enter the repo. Key generation and switching the Git remote are interactive, so they live in `run-ansible.sh` ([[bootstrap-installation]]):

- `generate_ssh_key`: `ssh-keygen -t ed25519`.
- `switch_remote_to_ssh`: prints the public key, waits until it is added on GitHub, then runs `git remote set-url`.
