# Testing

Molecule runs the playbook in Fedora containers as the non-root user `tester`.

## Requirements

Python 3.14, Podman, a checkout with submodules and LFS files.

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
```

## Run

```bash
molecule test -s desktop
molecule test -s server
```

Each run covers create, prepare, converge, idempotence, verify and destroy. A task reporting `changed` on the second converge fails the run.

## Debug

```bash
molecule converge -s server
molecule login -s server
molecule verify -s server
molecule destroy -s server
```

## Scenarios

| Scenario | Mode | Extra coverage |
|---|---|---|
| `desktop` | desktop | RPM Fusion, wallpapers via LFS, splash, konsave import |
| `server` | server | Neovim headless install, absence of desktop packages |

Shared settings live in `.config/molecule/config.yml`, playbooks in `molecule/shared/`.

## Not covered by containers

Flatpak apps, heavy desktop packages and applying the KDE profile need a real desktop. CI also runs the server mode on macOS.

## Lint

```bash
yamllint .
ansible-lint
git ls-files -z '*.sh' | xargs -0 shellcheck
```
