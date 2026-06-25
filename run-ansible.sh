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


# Schritt 2: SSH-Key Entscheidung

echo -e "${GELB}SSH-Key einrichten${RESET}"
echo ""

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo -e "  ${GELB}[!]${RESET} Es ist bereits ein SSH-Key vorhanden (~/.ssh/id_ed25519)"
    echo -e "      Ein neuer Key würde den alten ${ROT}überschreiben${RESET}."
else
    echo -e "  Kein SSH-Key gefunden – es kann ein neuer ed25519-Key generiert werden."
fi

echo ""

while true; do
    read -p "SSH-Key jetzt generieren? [j/n]: " ssh_auswahl < /dev/tty
    case $ssh_auswahl in
        [jJ]) GEN_SSH_KEY=true;  break ;;
        [nN]) GEN_SSH_KEY=false; break ;;
        *) echo "Bitte j oder n eingeben." ;;
    esac
done

echo ""
if [ "$GEN_SSH_KEY" = true ]; then
    erfolg "SSH-Key wird nach dem Setup generiert."
else
    info "SSH-Key Generierung übersprungen."
fi
echo ""


# Schritt 2b: Dotfiles-Repo auf SSH umstellen?

echo -e "${GELB}Dotfiles-Repo auf SSH umstellen${RESET}"
echo ""
echo -e "  Soll das geklonte dotfiles-Repo von HTTPS auf SSH umgestellt werden?"
echo -e "  (Ermöglicht das direkte Mitwirken am Repo per SSH-Authentifizierung)"
echo ""

while true; do
    read -p "Repo auf SSH umstellen? [j/n]: " ssh_remote_auswahl < /dev/tty
    case $ssh_remote_auswahl in
        [jJ]) CHANGE_TO_SSH=true;  break ;;
        [nN]) CHANGE_TO_SSH=false; break ;;
        *) echo "Bitte j oder n eingeben." ;;
    esac
done

echo ""
if [ "$CHANGE_TO_SSH" = true ]; then
    erfolg "Repo wird nach dem Setup auf SSH umgestellt."
else
    info "Repo bleibt auf HTTPS."
fi
echo ""


# Schritt 3: Git installieren (falls nötig)

if ! command -v git &> /dev/null; then
    info "Git wird installiert..."
    sudo dnf install -y git || fehler "Git konnte nicht installiert werden!"
fi
erfolg "Git ist bereit"


# Schritt 4: Ansible installieren (falls nötig)

if ! command -v ansible &> /dev/null; then
    info "Ansible wird installiert..."
    sudo dnf install -y ansible || fehler "Ansible konnte nicht installiert werden!"
fi
erfolg "Ansible ist bereit"


# Schritt 5: Dotfiles-Repo klonen (falls nötig)

if [ ! -d "$DOTFILES_DIR" ]; then
    info "Klone dotfiles-Repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR" || fehler "Repository konnte nicht geklont werden!"
else
    erfolg "dotfiles-Repository ist bereits vorhanden"
fi


# Schritt 6: Ansible Collections installieren

info "Installiere Ansible Collections..."
ansible-galaxy collection install -r "$DOTFILES_DIR/ansible/requirements.yml" \
    || fehler "Ansible Collections konnten nicht installiert werden!"
erfolg "Ansible Collections sind bereit"


# Schritt 7: Ansible Playbook ausführen
# --extra-vars übergibt den gewählten Modus an Ansible

info "Starte Ansible Playbook (Modus: ${INSTALL_MODE})..."
echo ""

ansible-playbook \
    -i "$DOTFILES_DIR/ansible/inventory.ini" \
    "$DOTFILES_DIR/ansible/setup.yml" \
    --extra-vars "install_mode=${INSTALL_MODE}" \
    --ask-become-pass \
    || fehler "Playbook fehlgeschlagen! Siehe Ausgabe oben."


# Schritt 8: SSH-Key generieren (interaktiv, mit eigenem Passphrase)

if [ "$GEN_SSH_KEY" = true ]; then
    bash "$DOTFILES_DIR/ansible/roles/ssh_config/tasks/generate_ssh_key.sh"
fi


# Schritt 9: Dotfiles-Repo auf SSH umstellen

if [ "$CHANGE_TO_SSH" = true ]; then
    echo ""
    echo -e "${GELB}Dotfiles-Repo auf SSH umstellen${RESET}"
    echo ""

    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        echo -e "  ${GELB}[!]${RESET} Kein SSH-Key gefunden – für den Repo-Wechsel wird ein Key benötigt."
        echo ""
        while true; do
            read -p "SSH-Key jetzt generieren? [j/n]: " retry_ssh < /dev/tty
            case $retry_ssh in
                [jJ])
                    bash "$DOTFILES_DIR/ansible/roles/ssh_config/tasks/generate_ssh_key.sh"
                    break ;;
                [nN])
                    info "SSH-Key Generierung übersprungen. Repo bleibt auf HTTPS."
                    break ;;
                *) echo "Bitte j oder n eingeben." ;;
            esac
        done
    fi

    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo ""
        echo -e "  ${GELB}Schritt 1: Dein öffentlicher SSH-Key${RESET}"
        echo ""
        cat "$HOME/.ssh/id_ed25519.pub"
        echo ""
        echo -e "  ${GELB}Schritt 2: SSH-Key zu GitHub hinzufügen${RESET}"
        echo -e "  Öffne: https://github.com/settings/keys"
        echo -e "  Klicke auf 'New SSH key' und füge den obigen Key ein."
        echo ""
        read -p "  Drücke [Enter], sobald du den Key zu GitHub hinzugefügt hast..." < /dev/tty
        echo ""
        echo -e "  ${GELB}Schritt 3: Remote URL auf SSH umstellen${RESET}"
        git -C "$DOTFILES_DIR" remote set-url origin git@github.com:JKZA-dev/dotfiles.git
        echo ""
        echo -e "  ${GELB}Schritt 4: Remote URL überprüfen${RESET}"
        git -C "$DOTFILES_DIR" remote -v
        echo ""
        erfolg "Repo wurde auf SSH umgestellt!"
    else
        info "Kein SSH-Key vorhanden – Repo bleibt auf HTTPS."
    fi
fi


# Fertig!

echo ""
echo -e "${GRUEN}  Setup abgeschlossen!${RESET}"
echo ""
echo "  Nächste Schritte:"

if [ "$INSTALL_MODE" = "desktop" ]; then
    echo "    1. Ausloggen/einloggen (damit ZSH + KDE-Profil aktiv wird)"
else
    echo "    1. Ausloggen/einloggen (damit ZSH aktiv wird)"
fi

echo ""
erfolg "Viel Spaß mit deinem neuen System! JKZA"
