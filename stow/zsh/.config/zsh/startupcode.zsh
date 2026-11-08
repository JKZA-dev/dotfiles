# Only the first shell of a terminal gets the banner.
[[ $SHLVL -eq 1 && -z $TMUX && -z $NVIM && $TERM_PROGRAM != vscode ]] || return 0

zsh --version
(( $+commands[fastfetch] )) && fastfetch --pipe false
cd
print -l "Einen guten Tag mein Herr, sie befinden sich auf ihrem"
device_model
print -l "" "Ich wünsche einen Produktiven Tag!"
