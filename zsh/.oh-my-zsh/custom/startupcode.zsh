# Direkte Ausgabe beim starten erlauben:
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

#Custom Code on Startup von mir selbst:
zsh --version
fastfetch --pipe false
cd
print -l "Einen guten Tag mein Herr, sie befinden sich auf ihrem" 
hostnamectl --json short | jq '(.HardwareVendor) + " " + (.HardwareModel)' -r
print -l "" "Ich wünsche einen Produktiven Tag!"
