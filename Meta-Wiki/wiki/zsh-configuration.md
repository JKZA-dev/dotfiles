# zsh

Oh-My-Zsh with Powerlevel10k and zsh-autosuggestions, all pinned submodules in `vendor/`, linked by the `shell` role ([[role-dotfiles-stow]]). None contain local changes. Dependabot proposes updates, so Oh-My-Zsh's own updater is disabled and its cache is redirected to `~/.cache/oh-my-zsh`.

| File (`stow/zsh/`) | Content |
|---|---|
| `.zshrc` | PATH, editors, Oh-My-Zsh setup |
| `.zprofile` | Homebrew environment and keg-only JDK (login shells, macOS) |
| `.p10k.zsh` | Prompt, generated with `p10k configure` |
| `.config/zsh/aliases.zsh` | Aliases; package management switches on `$OSTYPE` |
| `.config/zsh/device.zsh` | `device_model` |
| `.config/zsh/startupcode.zsh` | Startup banner |

`ZSH_CUSTOM` is `~/.config/zsh`, so Oh-My-Zsh sources those `*.zsh` files alphabetically.

## Banner
Prints only in the first shell of a terminal, not in tmux, Neovim or VS Code terminals. It changes to `~`, so "open terminal here" also starts in `~`.

## device_model
Prints vendor and model; `--refresh` re-detects and `--no-cache` bypasses the cache. A cache hit reads `~/.cache/device-model` without starting a process. Sources: `system_profiler` and `sysctl` on macOS; DMI, devicetree, then `hostnamectl` on Linux.
