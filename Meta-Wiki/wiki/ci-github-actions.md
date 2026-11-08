# CI

`.github/workflows/test-ansible.yml` runs on pushes to `main`, pull requests and manual dispatch. Newer runs cancel older ones on the same ref.

| Job | Content |
|---|---|
| `lint` | yamllint, `ansible-lint` with the production profile, shellcheck over tracked `*.sh` outside `kde/` |
| `molecule` | Matrix `desktop`, `server`, see [[testing-molecule]] |
| `macos` | Playbook in server mode on `macos-latest`, then a zsh start that must not write to stderr |

`molecule` and `macos` require `lint`. Tool versions are pinned in `requirements.txt`. Dependabot updates submodules and actions weekly.
