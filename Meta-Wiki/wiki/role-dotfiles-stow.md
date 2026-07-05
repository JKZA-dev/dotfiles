# Role: dotfiles (GNU Stow)

**Summary:** Uses GNU Stow to symlink the repo's `zsh`, `nvim`, and `fastfetch`
packages into `$HOME`, after backing up any conflicting real files.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`ansible/roles/dotfiles/tasks/main.yml`)
**Related:** [[ansible-architecture]], [[zsh-configuration]], [[neovim-configuration]], [[fastfetch-configuration]], [[testing-molecule]]
**Last updated:** 2026-06-21

---

## The Stow model

Each top-level folder (`zsh/`, `nvim/`, `fastfetch/`) mirrors the directory layout
starting at `$HOME`. Stow creates symlinks so the file exists once (in the repo) but
appears where the program expects it:

```
~/dotfiles/nvim/.config/nvim/init.lua  →  ~/.config/nvim/init.lua
~/dotfiles/zsh/.zshrc                  →  ~/.zshrc
~/dotfiles/zsh/.oh-my-zsh/custom/      →  ~/.oh-my-zsh/custom/
```

Everything is then versioned by Git from one place.

## Task sequence

1. **Back up Oh-My-Zsh custom files** that would block stow — moves
   `aliases.zsh`, `startupcode.zsh`, `Device.txt`, `example.zsh` to `.bak`
   (using `command` with `removes:` so it only runs if the file exists;
   `ignore_errors: true`). Oh-My-Zsh's installer drops its own versions of these.
2. **Back up `~/.zshrc`** — stat first; if it exists *and is not already a symlink*,
   move it to `.zshrc.bak`. (Avoids clobbering an existing real config; re-runs are safe.)
3. **Ensure `~/.config` exists** (`file: state=directory mode=0755`) so stow can put
   links inside it.
4. **Stow each package:**
   ```bash
   stow --restow --target=$HOME <package>   # for zsh, nvim, fastfetch
   ```
   `--restow` removes stale links and recreates them, so it is safe on repeated runs.
   `changed_when: true` is set because `stow` doesn't report change state to Ansible.

## Stowed packages

| Package | Links | Documented in |
|---------|-------|---------------|
| `zsh` | `.zshrc` + `.oh-my-zsh/custom/*` (incl. vendored Powerlevel10k, plugins) | [[zsh-configuration]] |
| `nvim` | `.config/nvim/` | [[neovim-configuration]] |
| `fastfetch` | `.config/fastfetch/` | [[fastfetch-configuration]] |

## Gotcha (from TESTING.md)

If a real file already sits where a symlink should go, stow errors with
`existing target is neither a link nor a directory`. The backup tasks above are meant
to prevent this; manual fix is to delete the stray file and `stow --restow` again.
