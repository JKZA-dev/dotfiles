# Direkte Ausgabe beim starten erlauben:
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

#Custom Code on Startup von mir selbst:
zsh --version
command -v fastfetch >/dev/null && fastfetch --pipe false
cd
print -l "Einen guten Tag mein Herr, sie befinden sich auf ihrem"
# Geraetemodell OS-neutral (Fedora + macOS), Ergebnis wird gecacht:
"${ZSH_CUSTOM:-$ZSH/custom}/bin/device-model.sh"
print -l "" "Ich wünsche einen Produktiven Tag!"
