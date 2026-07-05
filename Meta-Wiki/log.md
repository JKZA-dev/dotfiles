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
