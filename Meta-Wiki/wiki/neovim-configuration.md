# Neovim

LazyVim, `stow/nvim/.config/nvim/`. Extras are listed in `lazyvim.json`, plugin versions in `lazy-lock.json`.

The Java and Kotlin extras are imported in `lua/config/lazy.lua`, only when a JDK exists, so servers skip those tools. `/usr/bin/java` is a stub on macOS, hence the separate check.

## Unattended install
The `neovim` role runs on first setup only:
1. `nvim --headless +qa` clones plugins. `LAZY_LOCKFILE` points elsewhere because lazy.nvim rewrites the lockfile with partial data during this step.
2. `Lazy! restore` pins every plugin to `lazy-lock.json`.
3. `files/sync.lua` installs Mason tools and Tree-sitter parsers and blocks until done.

The toolchain (ripgrep, fd, fzf, gcc, tree-sitter-cli, Node, gh) is in the `base` package group; Java is in `desktop_heavy`. See [[role-packages]].

`claudecode.nvim` needs the `claude` CLI, which this setup does not install.
