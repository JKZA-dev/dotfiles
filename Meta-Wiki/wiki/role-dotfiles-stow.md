# Roles: dotfiles and shell

## dotfiles
Each directory in `stow/` mirrors `$HOME`. The role runs:

```bash
stow --no-folding --verbose --ignore=.DS_Store --dir=<repo>/stow --target=$HOME <package>
```

`--no-folding` is required: without it stow links whole directories, and applications then write into the repo.

Packages: `zsh`, `nvim`, `fastfetch`, and `backgrounds` on desktop. Real `.zshrc`, `.zprofile` and `.p10k.zsh` files are moved to `*.bak` first, because stow refuses to replace them.

## shell
Links `vendor/` into place, since submodules stay outside the stow packages:

| Link | Target |
|---|---|
| `~/.oh-my-zsh` | `vendor/ohmyzsh` |
| `~/.config/zsh/themes/powerlevel10k` | `vendor/powerlevel10k` |
| `~/.config/zsh/plugins/zsh-autosuggestions` | `vendor/zsh-autosuggestions` |

It also sets `/bin/zsh` as login shell. See [[zsh-configuration]].
