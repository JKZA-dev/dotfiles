# Role: ssh_config

**Summary:** Creates `~/.ssh` with 0700 perms and copies `known_hosts`; the public
key copy is intentionally disabled and the private key is never in the repo.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`ansible/roles/ssh_config/tasks/main.yml`)
**Related:** [[ansible-architecture]], [[bootstrap-installation]]
**Last updated:** 2026-06-21

---

## Tasks

1. **Create `~/.ssh/` with mode `0700`** — SSH refuses to use a world-accessible
   directory, so the strict permission is essential.
2. **Copy `known_hosts`** from `ssh/.ssh/known_hosts` in the repo to `~/.ssh/known_hosts`
   (mode `0644`).
3. **Debug reminder** to transfer the private key manually.

## Security model — keys

- **Private key (`id_ed25519`) is NOT in the repo** — by design. You either transfer
  it manually or generate a fresh one per machine, then `chmod 600 ~/.ssh/id_ed25519`.
- **Public key copy is commented out.** The reasoning recorded in the role: a new
  machine may want a brand-new keypair (or, for a server, none at all), so the role
  doesn't force the repo's public key onto it. The `.pub` still lives in the repo at
  `ssh/.ssh/id_ed25519.pub` for reference.

## Verified by tests

[[testing-molecule]] asserts `~/.ssh` exists, is a directory, has mode `0700`, and
that `known_hosts` is present.
