# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias ll="ls -l"
alias la="ls -a"
alias ff="fastfetch"
alias v="nvim"
alias sv="sudoedit"

#NeoVIM zu sudo editor machen
# Pfad nicht hardcoden: unter Fedora /usr/bin/nvim, per Homebrew
# /opt/homebrew/bin/nvim. command -v findet beides.
if command -v nvim >/dev/null; then
    export SUDO_EDITOR="$(command -v nvim)"
fi


# Paketverwaltung - je nach Betriebssystem dnf oder brew.
# $OSTYPE ist zsh-eigen: "linux-gnu" bzw. "darwin25.0".
case "$OSTYPE" in
    linux*)
        # dnf
        alias dp="sudo dnf install"
        alias dpy="sudo dnf install -y"
        alias upd="sudo dnf upgrade -y; sudo dnf autoremove -y; needs-reboot"
        # check if needs rebooting
        alias needs-reboot="needs-restarting -r ; echo $?"
        ;;
    darwin*)
        # homebrew - fragt von sich aus nicht nach, daher dp == dpy
        alias dp="brew install"
        alias dpy="brew install"
        alias upd="brew update && brew upgrade && brew cleanup"
        # kein needs-reboot-Aequivalent unter macOS
        ;;
esac



# Ze Funny
alias gay="| lolcat"

alias matrix="cmatrix"
alias gay-matrix="matrix | lolcat"

alias steam-locomotive="sl"
alias gay-locomotive="sl | lolcat"

alias yeet="rm"
alias FF="exit"
