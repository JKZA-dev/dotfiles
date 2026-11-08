#!/usr/bin/env bash
# Bootstraps this dotfiles setup on Fedora or macOS.
#   curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash
#   ssh -t user@host 'curl -fsSL https://raw.githubusercontent.com/JKZA-dev/dotfiles/main/run-ansible.sh | bash'
set -euo pipefail

readonly REPO_SLUG=JKZA-dev/dotfiles
readonly DOTFILES_DIR=${DOTFILES_DIR:-$HOME/dotfiles}
readonly SSH_KEY=$HOME/.ssh/id_ed25519
OS=$(uname -s)
readonly OS

log() { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
ok() { printf '\033[0;32m[OK]\033[0m %s\n' "$1"; }
die() {
    printf '\033[0;31m[ERROR]\033[0m %s\n' "$1" >&2
    exit 1
}

ask_yn() {
    local reply
    while read -r -p "$1 [y/n]: " reply </dev/tty; do
        case $reply in
            [yY]) return 0 ;;
            [nN]) return 1 ;;
        esac
    done
    die "Could not read from the terminal."
}

ask_mode() {
    local reply
    while read -r -p "Setup mode: [d]esktop or [s]erver: " reply </dev/tty; do
        case $reply in
            [dD]) INSTALL_MODE=desktop && return ;;
            [sS]) INSTALL_MODE=server && return ;;
        esac
    done
    die "Could not read from the terminal."
}

ask_questions() {
    GAMING=false KDE_APPLY=false GENERATE_KEY=false SWITCH_REMOTE=false

    ask_mode
    if [[ $INSTALL_MODE == desktop ]]; then
        if ask_yn "Install gaming packages (Steam, Prism Launcher)?"; then GAMING=true; fi
        if [[ $OS == Linux ]] && ask_yn "Apply the KDE profile (replaces the current layout)?"; then KDE_APPLY=true; fi
    fi
    [[ -f $SSH_KEY ]] && log "$SSH_KEY exists; ssh-keygen asks before overwriting it."
    if ask_yn "Generate an SSH key?"; then GENERATE_KEY=true; fi
    if ask_yn "Switch the dotfiles remote from HTTPS to SSH?"; then SWITCH_REMOTE=true; fi
}

install_homebrew() {
    command -v brew >/dev/null && return
    [[ -x /opt/homebrew/bin/brew ]] ||
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_prerequisites() {
    log "Installing git, git-lfs and Ansible..."
    case $OS in
        Linux)
            command -v dnf >/dev/null || die "Only Fedora is supported on Linux."
            sudo dnf install -y git git-lfs ansible
            ;;
        Darwin)
            install_homebrew
            brew install git git-lfs ansible
            ;;
        *) die "Unsupported OS: $OS" ;;
    esac
    git lfs install >/dev/null
}

sync_repo() {
    if [[ -e $DOTFILES_DIR/.git ]]; then
        log "Updating $DOTFILES_DIR..."
        git -C "$DOTFILES_DIR" pull --ff-only
        git -C "$DOTFILES_DIR" submodule update --init
    else
        log "Cloning into $DOTFILES_DIR..."
        git clone --recurse-submodules "https://github.com/$REPO_SLUG.git" "$DOTFILES_DIR"
    fi
}

run_playbook() {
    local extra_vars
    printf -v extra_vars '{"install_mode":"%s","gaming":%s,"kde_apply_profile":%s,"dotfiles_dir":"%s"}' \
        "$INSTALL_MODE" "$GAMING" "$KDE_APPLY" "$DOTFILES_DIR"

    cd "$DOTFILES_DIR/ansible"
    ansible-galaxy collection install -r requirements.yml
    ansible-playbook setup.yml --ask-become-pass --extra-vars "$extra_vars"
}

generate_ssh_key() {
    log "Starting ssh-keygen. The passphrase is neither shown nor stored."
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$SSH_KEY"
    ok "SSH key generated: $SSH_KEY"
}

switch_remote_to_ssh() {
    if [[ ! -f $SSH_KEY ]]; then
        ask_yn "No SSH key found. Generate one now?" || {
            log "No SSH key; the remote stays on HTTPS."
            return
        }
        generate_ssh_key
    fi

    cat "$SSH_KEY.pub"
    log "Add the key above at https://github.com/settings/keys"
    read -r -p "Press Enter when done..." </dev/tty

    git -C "$DOTFILES_DIR" remote set-url origin "git@github.com:$REPO_SLUG.git"
    git -C "$DOTFILES_DIR" remote -v
    ok "Remote switched to SSH."
}

main() {
    { : </dev/tty; } 2>/dev/null || die "This script is interactive and needs a TTY. Over SSH, use: ssh -t"

    ask_questions
    install_prerequisites
    sync_repo
    run_playbook

    if [[ $GENERATE_KEY == true ]]; then generate_ssh_key; fi
    if [[ $SWITCH_REMOTE == true ]]; then switch_remote_to_ssh; fi

    ok "Setup complete. Log out and back in to activate zsh."
}

main
