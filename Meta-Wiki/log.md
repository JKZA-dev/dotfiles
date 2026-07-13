# Ingest Log

Chronological record of every ingest operation performed on this wiki.

---

## Format

Each entry records:
- **Date** — when the ingest ran
- **Source** — the file added to `raw/`
- **Output** — the wiki page(s) created or updated in `wiki/`
- **Action** — `create`, `update`, or `merge`
- **Notes** — anything notable (conflicts, gaps, overlaps with existing pages)

---

## Log

<!-- Entries are prepended (newest first) -->

### 2026-07-13 — Gaming-Ready, automatischer Device-Banner, PR #14 (`dev` → `main`)

- **Action:** update
- **Output:** `wiki/bootstrap-installation.md`, `wiki/ansible-architecture.md`,
  `wiki/role-packages.md`, `wiki/desktop-vs-server.md`, `wiki/zsh-configuration.md`,
  `wiki/role-dotfiles-stow.md`, `index.md`, root `README.md`
- **Notes:**
  - Re-synced directly against the live repo state on `main` (git log + diffs), not a
    new raw snapshot — `dev` was merged into `main` via PR #14 (`1c28585`) since the
    last update, bringing in everything below.
  - **Gaming-Ready:** new opt-in asked during bootstrap (desktop only, Schritt 1b),
    `game_ready` extra-var, installs Steam (dnf5) + Prism Launcher (Flatpak, moved out
    of the regular desktop Flatpak list). Two follow-up fix commits added `| bool`
    casts to the `when:` conditions (raw `--extra-vars` strings aren't auto-coerced).
  - **Startup banner:** `custom/startupcode.zsh` now reads hardware vendor/model live
    via `hostnamectl --json short | jq -r ...` instead of the static `custom/Device.txt`
    file; `jq` added to the base package list. (A prior same-day wiki commit,
    `5c2ef18`, had already partially updated `zsh-configuration.md` but incorrectly
    described a Device.txt fallback that doesn't exist in the code — corrected here.)
  - **Drift fix (unrelated to the above, found during this sync):**
    `wiki/role-dotfiles-stow.md` still described the old `stow --restow` +
    `changed_when: true` approach; the actual task (changed back on 2026-06-29,
    commit range around `ae2ccc1`) uses `stow --verbose` + a `changed_when` on
    `LINK:`/`UNLINK:` in stderr. That earlier update touched
    `testing-molecule.md`/`ci-github-actions.md`/`role-packages.md`/
    `ansible-architecture.md` but missed this page.
  - `.gitignore` (new file) excludes `zsh/.oh-my-zsh/cache/.zsh-update` (noisy
    auto-generated timestamp); `jq` added to packages; a couple of typo fixes.
  - `README.md`: added the Gaming-Ready question to the setup description and the
    `jq` note; no structural changes needed otherwise.

### 2026-06-29 — Test-Suite repariert (Molecule + Lint) & Flatpak-Apps

- **Action:** update
- **Output:** `wiki/testing-molecule.md`, `wiki/ci-github-actions.md`,
  `wiki/role-packages.md`, `wiki/ansible-architecture.md`
- **Notes:**
  - **Molecule-Fixes:** Bootstrap (python3 + **python3-libdnf5** + sudo, Dotfiles
    kopieren) in neues `molecule/default/prepare.yml` ausgelagert → converge bleibt
    idempotent. Stow nutzt jetzt `--verbose` + `changed_when` statt `--restow` +
    `changed_when: true`. `ssh_config`-Copy bekam `remote_src: true`. `backgrounds`
    läuft jetzt auch im Container (nur `kde` bleibt über `molecule_test` ausgeschlossen).
  - **packages-Rolle:** Desktop-Pakete in „Basis" (`gimp`, auch im Test) und „schwer"
    (`kicad` u.a., via `not molecule_test`) gesplittet; Edge + Flatpak ebenso gegated;
    pip nutzt `--break-system-packages` (PEP 668).
  - **Flatpak-App-Liste** ersetzt den kaputten `com.example.App`-Platzhalter:
    `org.prismlauncher.PrismLauncher`, `im.riot.Riot`, `com.github.tchx84.Flatseal`,
    `com.ktechpit.whatsie`, `com.discordapp.Discord`.
  - **CI:** Zwei-Stufen-Aufbau — schneller `lint`-Job (yamllint, ansible-lint,
    `--syntax-check`, shellcheck) gated die `molecule`-Matrix (`needs: lint`). Trigger
    von `develop` auf `dev` korrigiert. Neue Configs `.yamllint`, `.ansible-lint`.
  - Behebt die zuvor in der Snapshot-Ingest notierten Punkte (Flatpak-Platzhalter;
    veraltetes Symlink-Layout in TESTING.md).

### 2026-06-25 — SSH-Key & HTTPS→SSH-Remote-Migration in run-ansible.sh

- **Action:** update
- **Output:** `wiki/bootstrap-installation.md`, `wiki/role-ssh.md`
- **Notes:**
  - `run-ansible.sh`: SSH-Key-Generierung und HTTPS→SSH-Umstellung als Entscheidungen
    upfront gesammelt (Schritte 2 & 2b); SSH-Keygen-Code in neues Hilfsskript
    ausgelagert; Schritt 8 ruft jetzt `generate_ssh_key.sh` auf; neuer Schritt 9
    führt die Remote-Umstellung durch inkl. zweiter SSH-Key-Chance und automatischer
    Ausführung der `execute`-Kommandos aus `HowToChangeOrigin.txt`.
  - Neues Skript: `ansible/roles/ssh_config/tasks/generate_ssh_key.sh`
  - `HowToChangeOrigin.txt` bleibt unverändert; die `execute`-Zeilen darin sind jetzt
    in Schritt 9 des Bootstrap-Scripts umgesetzt.

### 2026-06-21 — dotfiles repository self-ingest (`raw/2026-06-21-dotfiles-repo-snapshot.md`)

- **Action:** create
- **Source:** the dotfiles repo itself @ branch `JKZA-dev/issue8`, commit `5e8cb3c`
- **Output (13 pages):**
  `wiki/overview.md`, `wiki/bootstrap-installation.md`, `wiki/desktop-vs-server.md`,
  `wiki/ansible-architecture.md`, `wiki/role-packages.md`, `wiki/role-dotfiles-stow.md`,
  `wiki/role-ssh.md`, `wiki/role-kde-desktop.md`, `wiki/zsh-configuration.md`,
  `wiki/neovim-configuration.md`, `wiki/fastfetch-configuration.md`,
  `wiki/testing-molecule.md`, `wiki/ci-github-actions.md`
- **Notes:**
  - First ingest — seeded the whole wiki from the repository's own config & docs.
  - Vendored/generated trees were deliberately **excluded** (not distilled): full
    Oh-My-Zsh distribution, Powerlevel10k theme + gitstatus C++ source, binary
    wallpapers, the `.knsv` KDE profile archive, the third-party fastfetch KDE splash,
    nvim `lazy-lock.json`, and SSH key/host files. See the raw snapshot for the list.
  - Captured a few notable repo states worth revisiting: the Flatpak install list in
    the packages role is still a `com.example.App` placeholder; the email-on-failure
    CI step is commented out; `deps.sh.alt` is legacy (superseded by the vendored
    Oh-My-Zsh + Powerlevel10k stow approach); nvim config is near-stock LazyVim.
  - TESTING.md documents an older symlink-based molecule scenario layout; the current
    `molecule.yml` files use the `playbooks:` provisioner key instead. Noted the
    discrepancy in `wiki/testing-molecule.md`.

---
