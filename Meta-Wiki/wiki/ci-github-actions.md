# CI — GitHub Actions

**Summary:** A two-tier GitHub Actions workflow: a fast `lint` job (yamllint,
ansible-lint, syntax-check, shellcheck) gates a `molecule` matrix that runs the
`desktop` and `server` scenarios in parallel, on push/PR to main/dev and manual dispatch.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`.github/workflows/test-ansible.yml`, `.env.example`, `TESTING.md`)
**Related:** [[testing-molecule]], [[overview]]
**Last updated:** 2026-06-29

---

## Workflow — `Ansible Molecule Tests`

### Triggers

- `push` to `main` or `dev`
- `pull_request` to `main` or `dev`
- `workflow_dispatch` (manual; optional `scenario` input)

### Two tiers

**1. `lint` (seconds, no containers)** — runs on `ubuntu-latest`:
1. Checkout + Python 3.12.
2. `pip install ansible-core ansible-lint yamllint` and
   `ansible-galaxy collection install -r ansible/requirements.yml`.
3. `yamllint .` (config `.yamllint`, `extends: relaxed`).
4. `ansible-playbook --syntax-check -i ansible/inventory.ini ansible/setup.yml`.
5. `ansible-lint` (config `.ansible-lint`, `profile: min`).
6. `shellcheck run-ansible.sh ansible/roles/ssh_config/tasks/generate_ssh_key.sh`
   (shellcheck is preinstalled on GitHub runners).

**2. `molecule` (minutes)** — `needs: lint`, so the slow containers only start once
lint is green. Matrix over `scenario: [desktop, server]`, `fail-fast: false`. Steps:
1. Checkout + Python 3.12 (pip cache).
2. Install Podman via apt; print `podman version`.
3. `pip install -r requirements.txt` ([[testing-molecule]]).
4. `molecule test -s ${{ matrix.scenario }}` (env `PY_COLORS`, `ANSIBLE_FORCE_COLOR`,
   `MOLECULE_DRIVER_NAME=podman`). This includes the `prepare` stage that installs
   `python3-libdnf5` and copies dotfiles into the container.
5. **On failure:** upload `~/.cache/molecule/` + `/tmp/molecule/` as artifact
   `molecule-logs-<scenario>-<run_id>`, retained 30 days.
6. **Always:** `molecule destroy -s <scenario>` cleanup.

The two scenarios run in parallel, so molecule wall-clock is roughly halved.

## Cost

The repo is **public**, so GitHub Actions minutes are free (private repos get 2,000
free minutes/month). No cost for this repo.

## Optional email-on-failure (disabled)

A `dawidd6/action-send-mail` step is present but **commented out**. It would email on
push failures, guarded by SMTP secrets. `.github/workflows/.env.example` documents the
required (all optional) secrets — `MAIL_SERVER`, `MAIL_USERNAME`, `MAIL_PASSWORD`,
`MAIL_TO`, `MAIL_FROM` — added under Settings → Secrets and variables → Actions. If
unset, the step is skipped and tests still run.

## Manual run

Actions tab → "Ansible Molecule Tests" → "Run workflow" → optionally name a scenario
(blank = both).
