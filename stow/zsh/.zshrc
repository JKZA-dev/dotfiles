# Powerlevel10k instant prompt: must stay at the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -U path
path=("$HOME/.local/bin" $path)

export EDITOR=nvim
(( $+commands[nvim] )) && export SUDO_EDITOR=$commands[nvim]

export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$HOME/.config/zsh"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"
plugins=(git zsh-autosuggestions)

# Updated through the vendor/ submodules.
zstyle ':omz:update' mode disabled

source "$ZSH/oh-my-zsh.sh"

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# The startup banner prints during init; applied last to beat the wizard's value.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
