#!/bin/bash
#
# Generiert einen ed25519 SSH-Key interaktiv.
# Kann standalone oder aus run-ansible.sh heraus aufgerufen werden.
#

ROT='\033[0;31m'
GRUEN='\033[0;32m'
GELB='\033[1;33m'
BLAU='\033[0;34m'
RESET='\033[0m'

info()   { echo -e "${BLAU}[INFO]${RESET} $1"; }
erfolg() { echo -e "${GRUEN}[OK]${RESET} $1"; }

echo ""
echo -e "${GELB}SSH-Key generieren${RESET}"
echo ""
info "ssh-keygen wird gestartet – du kannst jetzt dein Passphrase eingeben."
info "Das Passphrase wird nicht angezeigt und nirgendwo gespeichert."
echo ""
ssh-keygen -t ed25519 -C "${USER}@$(hostname)"
echo ""
erfolg "SSH-Key generiert: ~/.ssh/id_ed25519"
