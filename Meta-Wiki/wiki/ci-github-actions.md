# CI — GitHub Actions

**Summary:** A GitHub Actions workflow runs the `desktop` and `server` Molecule
scenarios in parallel on push/PR to main/develop and on manual dispatch.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`.github/workflows/test-ansible.yml`, `.env.example`, `TESTING.md`)
**Related:** [[testing-molecule]], [[overview]]
**Last updated:** 2026-06-21

---

## Workflow — `Ansible Molecule Tests`

### Triggers

- `push` to `main` or `develop`
- `pull_request` to `main` or `develop`
- `workflow_dispatch` (manual; optional `scenario` input)

### Job matrix

One job `molecule` with a matrix over `scenario: [desktop, server]`, `fail-fast: false`
so both run to completion even if one fails. Runs on `ubuntu-latest`, `contents: read`.

### Steps

1. Checkout (`actions/checkout@v4`).
2. Python 3.12 with pip cache (`actions/setup-python@v5`).
3. Install Podman via apt; print `podman version`.
4. `pip install -r requirements.txt` ([[testing-molecule]]).
5. `molecule test -s ${{ matrix.scenario }}` (env: `PY_COLORS`, `ANSIBLE_FORCE_COLOR`,
   `MOLECULE_DRIVER_NAME=podman`).
6. **On failure:** upload `~/.cache/molecule/` + `/tmp/molecule/` as an artifact
   `molecule-logs-<scenario>-<run_id>`, retained 30 days.
7. **Always:** `molecule destroy -s <scenario>` cleanup.

Because the two scenarios run in parallel, total wall-clock is roughly halved.

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
