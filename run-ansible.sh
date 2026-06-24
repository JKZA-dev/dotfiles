#!/bin/bash
#
# Bootstrap-Script für dein Fedora Setup.
#
# Benutzung LOKAL:
#   curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash
#
# Benutzung per SSH:
#   ssh benutzer@neuer-pc 'curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash'
#

# Farben
ROT='\033[0;31m'
GRUEN='\033[0;32m'
GELB='\033[1;33m'
BLAU='\033[0;34m'
RESET='\033[0m'

info()    { echo -e "${BLAU}[INFO]${RESET} $1"; }
erfolg()  { echo -e "${GRUEN}[OK]${RESET} $1"; }
fehler()  { echo -e "${ROT}[FEHLER]${RESET} $1"; exit 1; }

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/JKZA-dev/dotfiles.git"

echo ""
echo -e "${GELB}  Fedora Workstation/Server Setup${RESET}"
echo ""


# Schritt 1: Installationsmodus wählen

echo -e "${GELB}Welches Setup möchtest du einrichten?${RESET}"
echo ""
echo "  1) Desktop  – Fedora KDE (Pakete, ZSH, Dotfiles, KDE-Profil, Wallpaper, ...)"
echo "  2) Server   – Fedora Server (Pakete, ZSH, Dotfiles, SSH – kein KDE/GUI)"
echo ""

while true; do
    read -p "Auswahl [1/2]: " auswahl < /dev/tty
    case $auswahl in
        1) INSTALL_MODE="desktop"; break ;;
        2) INSTALL_MODE="server";  break ;;
        *) echo "Bitte 1 oder 2 eingeben." ;;
    esac
done

echo ""
erfolg "Modus: ${INSTALL_MODE}"
echo ""


# Schritt 2: Git installieren (falls nötig)

if ! command -v git &> /dev/null; then
    info "Git wird installiert..."
    sudo dnf install -y git || fehler "Git konnte nicht installiert werden!"
fi
erfolg "Git ist bereit"


# Schritt 3: Ansible installieren (falls nötig)

if ! command -v ansible &> /dev/null; then
    info "Ansible wird installiert..."
    sudo dnf install -y ansible || fehler "Ansible konnte nicht installiert werden!"
fi
erfolg "Ansible ist bereit"


# Schritt 4: Dotfiles-Repo klonen (falls nötig)

if [ ! -d "$DOTFILES_DIR" ]; then
    info "Klone dotfiles-Repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR" || fehler "Repository konnte nicht geklont werden!"
else
    erfolg "dotfiles-Repository ist bereits vorhanden"
fi


# Schritt 5: Ansible Collections installieren

info "Installiere Ansible Collections..."
ansible-galaxy collection install -r "$DOTFILES_DIR/ansible/requirements.yml" \
    || fehler "Ansible Collections konnten nicht installiert werden!"
erfolg "Ansible Collections sind bereit"


# Schritt 6: Ansible Playbook ausführen
# --extra-vars übergibt den gewählten Modus an Ansible

info "Starte Ansible Playbook (Modus: ${INSTALL_MODE})..."
echo ""

ansible-playbook \
    -i "$DOTFILES_DIR/ansible/inventory.ini" \
    "$DOTFILES_DIR/ansible/setup.yml" \
    --extra-vars "install_mode=${INSTALL_MODE}" \
    --ask-become-pass \
    || fehler "Playbook fehlgeschlagen! Siehe Ausgabe oben."


# Fertig!

echo ""
echo -e "${GRUEN}  Setup abgeschlossen!${RESET}"
echo ""
echo "  Nächste Schritte:"
echo "    1. SSH Public + Private Key manuell übertragen + chmod 600 ~/.ssh/id_ed25519"

if [ "$INSTALL_MODE" = "desktop" ]; then
    echo "    2. Ausloggen/einloggen (damit ZSH + KDE-Profil aktiv wird)"
else
    echo "    2. Ausloggen/einloggen (damit ZSH aktiv wird)"
fi

echo ""
erfolg "Viel Spaß mit deinem neuen System! JKZA"
