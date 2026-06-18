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
export SUDO_EDITOR="/usr/bin/zsh"

# dnf 
alias dp="sudo dnf install"
alias dpy="sudo dnf install -y"
alias upd="sudo dnf upgrade -y; sudo dnf autoremove -y; needs-reboot"
# check if needs rebooting
alias needs-reboot="needs-restarting -r ; echo $?"



# Ze Funny
alias gay="| lolcat"

alias matrix="cmatrix"
alias gay-matrix="matrix | lolcat"

alias steam-locomotive="sl"
alias gay-locomotive="sl | lolcat" 

alias yeet="rm"
alias FF="exit"
