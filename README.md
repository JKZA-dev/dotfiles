# dotfiles

[![Tests](https://github.com/JKZA-dev/dotfiles/actions/workflows/test-ansible.yml/badge.svg)](https://github.com/JKZA-dev/dotfiles/actions/workflows/test-ansible.yml)

Mein komplettes Fedora Setup – automatisiert mit Ansible.

**Ein Befehl, fertig eingerichteter PC.**

## Inhalt

- [Was ist das?](#was-ist-das)
- [Voraussetzungen](#voraussetzungen)
- [Setup auf neuem Rechner](#setup-auf-neuem-rechner)
- [Desktop vs Server](#desktop-vs-server)
- [Nach dem Setup](#nach-dem-setup)
- [Einzelne Teile ausführen](#einzelne-teile-ausführen)
- [Testing](#testing)
- [Struktur](#struktur)
- [Dokumentation](#dokumentation)
- [Lizenz](#lizenz)

## Was ist das?

Dieses Repo ist mein gesamtes Fedora-Environment as Code: System-Pakete, ZSH +
Oh-My-Zsh + Powerlevel10k, Neovim, Fastfetch, SSH-Konfiguration und (auf dem
Desktop) mein KDE-Plasma-Profil inkl. Wallpaper – alles über ein Ansible-Playbook
reproduzierbar, alles per [GNU Stow](https://www.gnu.org/software/stow/) verlinkt
statt kopiert. Ein `run-ansible.sh` bootstrapt eine frische Fedora-Installation
komplett.

Läuft in zwei Modi:
- **Desktop** – volles KDE-Setup inkl. GUI-Paketen, Wallpaper, KDE-Profil, optional
  Gaming-Pakete (Steam, Prism Launcher).
- **Server** – headless: nur Shell, Dotfiles, SSH.

Die Playbooks werden bei jedem Push per **GitHub Actions** gegen beide Modi in
Podman-Containern getestet (siehe [Testing](#testing)).

## Voraussetzungen

- Ein frisch installiertes **Fedora** (Workstation für Desktop-Modus, Fedora
  Server für Server-Modus)
- Ein Benutzer mit `sudo`-Rechten
- Internetverbindung

Git und Ansible selbst müssen **nicht** vorinstalliert sein – das übernimmt das
Bootstrap-Script.

## Setup auf neuem Rechner

**Lokal** (direkt auf dem neuen PC):
```bash
curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash
```

**Per SSH** (von einem anderen Rechner aus):
```bash
ssh benutzer@neuer-pc 'curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash'
```

Das Script fragt dich der Reihe nach:
1. **Desktop** oder **Server**?
2. (nur Desktop) **Gaming-Ready** einrichten? – installiert zusätzlich Steam + Prism Launcher.
3. Jetzt einen **SSH-Key** generieren?
4. Das geklonte Repo von HTTPS auf **SSH umstellen** (zum Mitentwickeln)?

Danach installiert es Git + Ansible (falls nötig), klont dieses Repo nach
`~/dotfiles`, installiert die benötigten Ansible-Collections und führt das
Playbook mit deinen Antworten aus. Details zu jedem Schritt stehen im
[Meta-Wiki](Meta-Wiki/wiki/bootstrap-installation.md).

## Desktop vs Server

| | Desktop (KDE) | Server |
|---|:---:|:---:|
| Basis-Pakete (zsh, neovim, btop, ...) | ✅ | ✅ |
| ZSH + Oh-My-Zsh + Powerlevel10k | ✅ | ✅ |
| Dotfiles per Stow (nvim, fastfetch) | ✅ | ✅ |
| SSH-Dateien | ✅ | ✅ |
| GUI-Pakete (gimp, kicad, Edge) | ✅ | ❌ |
| Hintergrundbilder | ✅ | ❌ |
| KDE Konsave Profil | ✅ | ❌ |
| Gaming-Pakete (Steam, Prism Launcher) | optional | ❌ |

Gaming-Pakete sind ein eigener, unabhängiger Opt-in innerhalb des Desktop-Modus
(Frage 2 oben) – im Server-Modus wird die Frage gar nicht erst gestellt.

## Nach dem Setup

1. SSH Public + Private Key manuell übertragen (falls nicht neu generiert) →
   `chmod 600 ~/.ssh/id_ed25519`
2. Ausloggen/einloggen (damit ZSH aktiv wird)
3. (Desktop) Das KDE-Profil wird bereits während des Setups interaktiv abgefragt

## Einzelne Teile ausführen

```bash
cd ~/dotfiles

# Nur Pakete
ansible-playbook -i ansible/inventory.ini ansible/setup.yml --tags packages --extra-vars "install_mode=desktop" --ask-become-pass

# Nur Server-Pakete
ansible-playbook -i ansible/inventory.ini ansible/setup.yml --tags packages --extra-vars "install_mode=server" --ask-become-pass

# Nur Dotfiles verlinken (kein sudo nötig)
ansible-playbook -i ansible/inventory.ini ansible/setup.yml --tags dotfiles
```

Jede Rolle (`packages`, `zsh`, `dotfiles`, `ssh`, `backgrounds`, `kde`) hat einen
eigenen Tag.

## Testing

Die Playbooks laufen per **Molecule** in Podman-Containern (`desktop`- und
`server`-Szenario) durch create → converge → idempotency-check → verify. CI
(GitHub Actions) gated das über einen schnellen `lint`-Job (yamllint,
ansible-lint, shellcheck), bevor die Molecule-Matrix startet.

```bash
pip install -r requirements.txt   # ansible, molecule, molecule-plugins[podman]

molecule test -s desktop
molecule test -s server
```

Ausführliche Anleitung, Fehlerbilder und wie man neue Tests hinzufügt: siehe
[TESTING.md](TESTING.md).

## Struktur

```
~/dotfiles/
├── run-ansible.sh              ← Einstiegspunkt (fragt Desktop/Server, Gaming-Ready, SSH)
├── ansible/
│   ├── setup.yml                ← Haupt-Playbook
│   ├── inventory.ini             ← Zielrechner (localhost)
│   ├── requirements.yml          ← Ansible-Collections (community.general)
│   └── roles/
│       ├── packages/             ← System-Pakete (Basis + Desktop + Gaming)
│       ├── zsh/                  ← ZSH als Standard-Shell
│       ├── dotfiles/             ← Stow-Symlinks (zsh, nvim, fastfetch)
│       ├── ssh_config/           ← SSH-Dateien, Keygen-Skript
│       ├── backgrounds/          ← Wallpaper (nur Desktop)
│       └── kde/                  ← KDE-Profil per Konsave (nur Desktop)
├── zsh/                          ← ZSH-Dotfiles inkl. vendortem Oh-My-Zsh + Powerlevel10k
├── nvim/                         ← Neovim-Config (LazyVim, stow-kompatibel)
├── fastfetch/                    ← Fastfetch-Config (stow-kompatibel)
├── ssh/                          ← SSH Public Key + known_hosts
├── konsave/                      ← KDE-Plasma-Profil (.knsv-Archiv)
├── Backgrounds/                  ← Hintergrundbilder (Hacknet-Wallpaper)
├── applets/window-title/         ← Git-Submodul: KDE-Window-Title-Applet (Referenz/Quelle)
├── fastfetch-Splashscreen/       ← Vendorter KDE-Splashscreen-Plasmoid (Referenz)
├── molecule/                     ← Molecule-Testszenarien (desktop/server)
├── .github/workflows/            ← CI (Lint + Molecule-Matrix)
├── Meta-Wiki/                    ← Vertiefte Doku (Architektur, Rollen, Testing, CI)
├── TESTING.md                    ← Ausführliche Testing-Anleitung
├── requirements.txt               ← Python-Deps für Molecule (pip install -r)
├── userinstalled.txt              ← Manuelle Notiz: was per dnf history installiert ist
├── deps.sh.alt                    ← Alter Bootstrap-Ansatz, abgelöst durch run-ansible.sh
└── CLAUDE.md                      ← Kontext für Claude Code / AI-Assistenten
```

`applets/window-title/` und `fastfetch-Splashscreen/` sind vendorte Referenzquellen
und werden **nicht** automatisch von Ansible installiert – das tatsächlich genutzte
KDE-Window-Title-Applet steckt fertig gebündelt im Konsave-Profil
(`konsave/JKZA-KDE-Workstation.knsv`).

## Dokumentation

Für alles, was über dieses README hinausgeht – Architektur, jede Rolle im Detail,
Testing-Interna, CI-Aufbau – siehe das [Meta-Wiki](Meta-Wiki/index.md). Es ist die
Quelle der Wahrheit für Details; dieses README bleibt bewusst kurz.

## Lizenz

Keine Lizenz – privates Setup für den eigenen Gebrauch. Nutzung/Anpassung auf
eigene Gefahr.
