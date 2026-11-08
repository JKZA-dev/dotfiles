[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Keg-only JDK for jdtls and the Kotlin LSP.
[[ -d /opt/homebrew/opt/openjdk/bin ]] && path=(/opt/homebrew/opt/openjdk/bin $path)
