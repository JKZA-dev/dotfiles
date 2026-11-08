alias ll="ls -l"
alias la="ls -a"
alias ff="fastfetch"
alias v="nvim"
alias sv="sudoedit"

# Package management
case "$OSTYPE" in
  linux*)
    alias dp="sudo dnf install"
    alias dpy="sudo dnf install -y"
    alias upd="sudo dnf upgrade -y && sudo dnf autoremove -y; needs-reboot"
    alias needs-reboot='dnf needs-restarting -r; echo $?'
    ;;
  darwin*)
    alias dp="brew install"
    alias dpy="brew install" # brew never prompts
    alias upd="brew update && brew upgrade && brew cleanup"
    ;;
esac

# Ze Funny
alias -g gay="| lolcat"
alias matrix="cmatrix"
alias gay-matrix="matrix | lolcat"
alias steam-locomotive="sl"
alias gay-locomotive="sl | lolcat"
alias yeet="rm"
alias FF="exit"
