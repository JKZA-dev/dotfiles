# Testing

Molecule with the Podman driver and a pinned Fedora image. Usage is in `TESTING.md`.

- `.config/molecule/config.yml`: shared settings and test toggles.
- `molecule/{desktop,server}/molecule.yml`: platform and `install_mode`.
- `molecule/shared/`: `prepare`, `converge`, `verify`.

`prepare` runs as root, creates the user `tester` and copies the repo to `/home/tester/dotfiles`. Everything after runs as `tester`, matching a real installation.

`verify` checks packages per mode, login shell, that links point into the repo, `~/.ssh` permissions, known hosts, real wallpapers rather than LFS pointers, Neovim plugins (server) and the splash and konsave profile (desktop).

Idempotence failures mean a task reports `changed` on the second converge.
