# Testing Guide – Ansible Molecule

Dieses Dokument erklärt, wie die Ansible-Playbooks mit **Molecule** getestet werden
können – lokal auf deinem Rechner und automatisch via **GitHub Actions**.

---

## Inhaltsverzeichnis

1. [Was ist Molecule?](#was-ist-molecule)
2. [Lokale Voraussetzungen](#lokale-voraussetzungen)
3. [Installation](#installation)
4. [Tests lokal ausführen](#tests-lokal-ausführen)
5. [Test-Szenarien verstehen](#test-szenarien-verstehen)
6. [GitHub Actions – Automatische Tests](#github-actions--automatische-tests)
7. [Testergebnisse interpretieren](#testergebnisse-interpretieren)
8. [Häufige Fehler & Lösungen](#häufige-fehler--lösungen)
9. [Neue Tests hinzufügen](#neue-tests-hinzufügen)

---

## Was ist Molecule?

**Ansible Molecule** ist ein Test-Framework speziell für Ansible-Playbooks und -Rollen.
Es automatisiert den kompletten Testzyklus:

```
Create → Converge → Verify → Destroy
  ↓           ↓          ↓        ↓
Container  Playbook   Prüfungen  Cleanup
erstellen  ausführen  laufen     Container
```

### Warum testen?

| Ohne Tests                          | Mit Molecule                          |
|-------------------------------------|---------------------------------------|
| Fehler erst auf echtem System       | Fehler in isoliertem Container        |
| Regressions möglich                 | Automatischer Regressionsschutz       |
| Manuelle Überprüfung nötig          | Automatische Verifikation             |
| Kein Feedback bei Pull Requests     | CI zeigt sofort Pass/Fail             |

---

## Lokale Voraussetzungen

- **Fedora** (oder anderes Linux mit Podman-Support)
- **Python 3.10+**
- **Podman** (für Container)

Podman installieren (falls nicht vorhanden):

```bash
sudo dnf install podman     # Fedora
sudo apt install podman     # Ubuntu/Debian
```

---

## Installation

```bash
# Im dotfiles-Verzeichnis:
pip install -r requirements.txt

# Oder in einer virtuellen Umgebung (empfohlen):
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Installation prüfen:

```bash
molecule --version
ansible --version
podman --version
```

---

## Tests lokal ausführen

### Vollständiger Test-Zyklus (empfohlen)

```bash
# Desktop-Szenario (Standard)
molecule test

# Explizit Desktop
molecule test -s desktop

# Server-Szenario
molecule test -s server
```

`molecule test` führt automatisch diese Schritte durch:
1. **dependency** – Ansible-Galaxy-Abhängigkeiten laden
2. **create** – Fedora-Container mit Podman erstellen
3. **prepare** – `molecule/default/prepare.yml`: python3/python3-libdnf5/sudo
   installieren und Dotfiles in den Container kopieren (läuft EINMALIG)
4. **converge** – Ansible-Playbook (`ansible/setup.yml`) im Container ausführen
5. **idempotency** – Playbook ein zweites Mal ausführen (darf keine Änderungen machen)
6. **verify** – Verifikations-Playbook ausführen
7. **cleanup** – *(nicht verwendet)*
8. **destroy** – Container löschen

> **Hinweis Idempotenz:** Die Container-Vorbereitung steckt bewusst in
> `prepare.yml` (statt in `converge.yml`), damit der zweite converge-Lauf
> 0 Änderungen meldet. Die Stow-Rolle erkennt über `--verbose`, ob sie
> wirklich Symlinks anlegt – nur dann gilt sie als „changed".

### Einzelne Schritte ausführen

```bash
# Container erstellen
molecule create -s desktop

# Playbook ausführen (ohne Destroy)
molecule converge -s desktop

# Nochmal ohne Neustart (für schnelles Iterieren)
molecule converge -s desktop

# Nur Verifikation
molecule verify -s desktop

# In den Container einloggen (für Debugging)
molecule login -s desktop

# Container löschen
molecule destroy -s desktop
```

### Nützliche Flags

```bash
# Nur bestimmte Tags ausführen
molecule converge -s desktop -- --tags packages

# Bestimmte Tags überspringen
molecule converge -s desktop -- --skip-tags ssh

# Ausführlichere Ausgabe
molecule test -s server -- -v

# Noch ausführlicher
molecule test -s server -- -vvv
```

---

## Test-Szenarien verstehen

### Verzeichnisstruktur

```
molecule/
├── default/              # Basis-Szenario (Desktop) – hier liegen die echten Playbooks
│   ├── molecule.yml      # Container- und Provisioner-Konfiguration
│   ├── prepare.yml       # Container-Bootstrap (python3/libdnf5, Dotfiles kopieren)
│   ├── converge.yml      # importiert ansible/setup.yml
│   └── verify.yml        # Verifikations-Playbook (prüft Ergebnisse)
├── desktop/              # Desktop-Szenario
│   └── molecule.yml      # install_mode: desktop, verweist via "playbooks:" auf ../default
└── server/               # Server-Szenario
    └── molecule.yml      # install_mode: server,  verweist via "playbooks:" auf ../default
```

`desktop` und `server` enthalten KEINE eigenen Playbooks (auch keine Symlinks):
ihre `molecule.yml` zeigt über den `playbooks:`-Schlüssel auf `../default/`
(prepare, converge, verify) und unterscheidet sich nur in `install_mode`.

### Szenario: `desktop`

- Container: `quay.io/fedora/fedora:latest` (privileged)
- Variable: `install_mode=desktop`, `molecule_test=true`
- Getestete Rollen: packages, zsh, dotfiles, ssh_config, backgrounds
- Übersprungen: kde (interaktive Pause-Tasks, benötigt KDE-Session)
- Im Test übersprungene Pakete (über `molecule_test`): kicad, microsoft-edge,
  Flatpak – das hält die CI schnell und stabil. `gimp` wird als Beleg für den
  Desktop-Zweig installiert. Auf echten Maschinen wird alles installiert.

**Was wird geprüft:**
- ✅ Basis-Pakete installiert (zsh, neovim, btop, fastfetch, git, stow)
- ✅ Desktop-Paket installiert (gimp)
- ✅ ZSH ist Standard-Shell
- ✅ Dotfiles-Symlinks vorhanden (.zshrc, .config/nvim, .config/fastfetch)
- ✅ SSH-Verzeichnis mit korrekten Berechtigungen (0700)
- ✅ known_hosts vorhanden
- ✅ ~/Pictures/Hacknet/ vorhanden (Hintergrundbilder)

### Szenario: `server`

- Container: `quay.io/fedora/fedora:latest` (privileged)
- Variable: `install_mode=server`
- Getestete Rollen: packages, zsh, dotfiles, ssh_config
- Übersprungen: backgrounds, kde

**Was wird geprüft:**
- ✅ Basis-Pakete installiert
- ✅ ZSH ist Standard-Shell
- ✅ Dotfiles-Symlinks vorhanden
- ✅ SSH-Verzeichnis korrekt
- ✅ KEINE Desktop-Pakete (kein gimp, kicad, plasma-browser-integration)

---

## GitHub Actions – Automatische Tests

### Kostet das Geld?

**Für öffentliche Repositories: KOSTENLOS!**

GitHub Actions bietet für öffentliche Repositories **unbegrenzte** CI-Minuten kostenlos.
Für private Repositories gibt es 2.000 Freiminuten pro Monat (danach kostenpflichtig).

Da `JKZA-dev/dotfiles` ein öffentliches Repository ist, entstehen **keine Kosten**.

### Zwei-Stufen-Aufbau (Lint + Molecule)

Die CI läuft in zwei Stufen, von schnell nach langsam:

1. **`lint`** (Sekunden) – ohne Container:
   - `yamllint` – YAML-Syntax
   - `ansible-playbook --syntax-check` – Playbook-Struktur
   - `ansible-lint` – Ansible-Best-Practices (Profil `min`, siehe `.ansible-lint`)
   - `shellcheck` – die eigenen Shell-Skripte (`run-ansible.sh`,
     `generate_ssh_key.sh`)
2. **`molecule [desktop|server]`** (Minuten) – führt das Playbook real im
   Fedora-Container aus. Startet nur, wenn `lint` grün ist (`needs: lint`).

So bekommst du die meisten Fehler in Sekunden gemeldet, ohne auf die Container
zu warten.

### Wann laufen die Tests?

Die Tests werden automatisch ausgelöst bei:

| Ereignis                        | Beschreibung                              |
|---------------------------------|-------------------------------------------|
| `push` auf `main`               | Bei jedem Commit auf main                 |
| `push` auf `dev`                | Bei jedem Commit auf dev                  |
| Pull Request auf `main`         | Bei jedem PR (auch Updates)               |
| Pull Request auf `dev`          | Bei jedem PR auf dev                      |
| Manuell via Actions-Tab         | Jederzeit per Knopfdruck auslösbar        |

### Tests manuell starten

1. Gehe zu `https://github.com/JKZA-dev/dotfiles/actions`
2. Klicke auf **"Ansible Molecule Tests"** in der linken Sidebar
3. Klicke auf **"Run workflow"** (grüner Button rechts)
4. Optionales Szenario eingeben oder leer lassen (beide laufen dann)
5. **"Run workflow"** bestätigen

### Workflow-Struktur

```
Ansible Molecule Tests
├── Molecule [desktop]   ─┐
│   ├── Checkout         │
│   ├── Python 3.12      │ parallel
│   ├── Podman install   │
│   ├── pip install -r   │
│   ├── molecule test    │
│   └── Cleanup          │
│                        │
└── Molecule [server]   ─┘
    ├── Checkout
    ├── Python 3.12
    ├── Podman install
    ├── pip install -r
    ├── molecule test
    └── Cleanup
```

Beide Szenarien laufen **parallel**, was die Gesamtdauer halbiert.

### Test-Artifacts

Bei einem fehlgeschlagenen Test werden automatisch Logs als Artifact gespeichert
(30 Tage aufbewahrt). Zu finden unter:

`GitHub → Actions → (fehlgeschlagener Run) → Artifacts → molecule-logs-<szenario>`

---

## Testergebnisse interpretieren

### Erfolgreicher Testlauf

```
PLAY [Verify – Fedora Setup überprüfen] ****

TASK [Basis-Pakete sind installiert] ***
ok: [fedora-desktop] => {
    "changed": false,
    "msg": "Alle Basis-Pakete sind installiert"
}

TASK [ZSH ist Standard-Shell für root] ***
ok: [fedora-desktop] => {
    "changed": false,
    "msg": "ZSH ist die Standard-Shell für root"
}

...

PLAY RECAP ***
fedora-desktop : ok=12  changed=0  unreachable=0  failed=0
```

→ Alle Tasks `ok`, keine `failed` → **BESTANDEN** ✅

### Fehlgeschlagener Test

```
TASK [Dotfiles-Symlinks existieren und sind Symlinks] ***
fatal: [fedora-desktop]: FAILED! => {
    "assertion": "item.stat.islnk",
    "msg": "nvim config Symlink fehlt oder ist kein Symlink: exists=false"
}
```

→ `fatal` zeigt den fehlgeschlagenen Check mit Fehlermeldung

### Idempotenz-Fehler

```
PLAY RECAP (idempotency) ***
fedora-desktop : ok=15  changed=3  unreachable=0  failed=0
WARNING: idempotency test FAILED because 3 tasks reported "changed"
```

→ Das Playbook ist **nicht idempotent**: Es macht beim 2. Ausführen noch Änderungen.
→ Lösung: Betroffene Tasks so schreiben, dass sie bei Wiederholung keine Änderungen melden.

---

## Häufige Fehler & Lösungen

### `Permission denied` beim Starten von Podman

```
Error: permission denied while trying to connect to the Podman socket
```

**Lösung:**
```bash
# Podman-Socket starten
systemctl --user start podman.socket

# Oder mit Root-Podman testen
sudo molecule test -s desktop
```

### `Image not found` Fehler

```
Error: image not known: quay.io/fedora/fedora:latest
```

**Lösung:**
```bash
# Image manuell pullen
podman pull quay.io/fedora/fedora:latest
```

### `dnf5` nicht gefunden im Container

```
ModuleNotFoundError: No module named 'libdnf5'
```

**Lösung:** Das Container-Image muss Fedora 41+ sein (mit dnf5).
Das converge.yml installiert die Python-Bindings automatisch über den Bootstrap-Schritt.

### Molecule-Version inkompatibel

```
ERROR: molecule 6.x requires ansible-core 2.15+
```

**Lösung:**
```bash
pip install --upgrade -r requirements.txt
```

### Stow-Fehler: `existing target is neither a link nor a directory`

```
WARNING! stow: BUG in find_stowed_path ...
```

**Lösung:** Eventuell gibt es schon eine reale Datei an der Stelle des Symlinks.
Das Backup-Task im Dotfiles-Role sollte dies behandeln. Zum manuellen Bereinigen:
```bash
molecule login -s desktop
# Im Container:
rm ~/.zshrc
stow --restow --target=/root zsh
```

---

## Neue Tests hinzufügen

### Neue Verifikation in `verify.yml`

```yaml
# Beispiel: Prüfen ob ein Konfigurationsfile das richtige Inhalt hat
- name: Prüfen ob neovim init.lua existiert
  ansible.builtin.stat:
    path: /root/.config/nvim/init.lua
  register: nvim_init

- name: Neovim init.lua ist vorhanden
  ansible.builtin.assert:
    that:
      - nvim_init.stat.exists
    fail_msg: "nvim/init.lua fehlt"
    success_msg: "nvim/init.lua ist vorhanden"
```

### Neue Rolle testen

1. Rolle in `ansible/roles/<name>/tasks/main.yml` erstellen
2. In `converge.yml` unter `roles:` hinzufügen
3. Entsprechende Verifikation in `verify.yml` ergänzen

### Neues Szenario erstellen

```bash
# Beispiel: minimal-Szenario
mkdir molecule/minimal
cp molecule/server/molecule.yml molecule/minimal/molecule.yml
# molecule.yml anpassen (andere install_mode o.ä.)
ln -s ../default/converge.yml molecule/minimal/converge.yml
ln -s ../default/verify.yml molecule/minimal/verify.yml
```
