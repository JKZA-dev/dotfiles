# dotfiles 

Mein komplettes Fedora Setup – automatisiert mit Ansible.

**Ein Befehl, fertig eingerichteter PC.**


## Setup auf neuem Rechner

**Lokal** (direkt auf dem neuen PC):
```bash
curl -fsSL https://raw.githubusercontent.com/DEIN_USER/dotfiles/main/run-ansible.sh | bash
```

**Per SSH** (von einem anderen Rechner aus):
```bash
ssh benutzer@neuer-pc 'curl -fsSL https://raw.githubusercontent.com/DEIN_USER/dotfiles/main/run-ansible.sh | bash'
```

Das Script fragt dich ob **Desktop** oder **Server**, installiert Git + Ansible,
klont dieses Repo und richtet alles ein.


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


## Nach dem Setup

1. SSH Private Key manuell übertragen → `chmod 600 ~/.ssh/id_ed25519`
2. Ausloggen/einloggen (damit ZSH aktiv wird)
3. (Desktop) KDE-Profil wird während Setup nachgefragt


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


## Struktur

```
~/dotfiles/
├── run-ansible.sh              ← Einstiegspunkt (fragt Desktop/Server)
├── ansible/
│   ├── setup.yml               ← Haupt-Playbook
│   ├── inventory.ini           ← Zielrechner (localhost)
│   └── roles/
│       ├── packages/           ← System-Pakete (Basis + Desktop)
│       ├── zsh/                ← ZSH + Oh-My-Zsh
│       ├── dotfiles/           ← Stow Symlinks
│       ├── ssh_config/         ← SSH-Dateien
│       ├── backgrounds/        ← Wallpaper (nur Desktop)
│       └── kde/                ← KDE Profil (nur Desktop)
├── zsh/                        ← ZSH Dotfiles (stow-kompatibel)
├── nvim/                       ← Neovim Config (stow-kompatibel)
├── fastfetch/                  ← Fastfetch Config (stow-kompatibel)
├── ssh/                        ← SSH Public Key
├── konsave/                    ← KDE Plasma Profil
└── Backgrounds/                ← Hintergrundbilder
```
