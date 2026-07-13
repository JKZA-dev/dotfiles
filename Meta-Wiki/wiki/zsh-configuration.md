# ZSH Configuration

**Summary:** The shell is ZSH + Oh-My-Zsh with the Powerlevel10k theme; the repo
bundles the whole Oh-My-Zsh tree and adds custom aliases plus a themed startup banner.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`zsh/.zshrc`, `custom/aliases.zsh`, `custom/startupcode.zsh`, `custom/Device.txt`)
**Related:** [[role-dotfiles-stow]], [[ansible-architecture]], [[role-packages]], [[neovim-configuration]], [[fastfetch-configuration]]
**Last updated:** 2026-07-13

---

## Layout

The whole `zsh/` folder is a stow package ([[role-dotfiles-stow]]). It contains both
`.zshrc` and a **vendored Oh-My-Zsh distribution** under `.oh-my-zsh/` (all standard
plugins/libs plus the Powerlevel10k theme and its gitstatus C++ helper). The
`ansible` zsh role only sets `/bin/zsh` as the default shell ([[ansible-architecture]]).

`.gitignore` (repo root) excludes `zsh/.oh-my-zsh/cache/.zsh-update` — Oh-My-Zsh
rewrites this auto-update-check timestamp on its own, so committing it just produced
noisy diffs.

## `.zshrc` highlights

- **Powerlevel10k instant prompt** block at the top (sources the cached prompt).
- `ZSH_THEME="powerlevel10k/powerlevel10k"`.
- `ENABLE_CORRECTION="true"` — command auto-correction on.
- **Plugins:** `git`, `zsh-autosuggestions`.
- `export EDITOR='nvim'`.
- Sources `~/.p10k.zsh` if present.
- `POWERLEVEL9K_INSTANT_PROMPT=quiet`.
- `export PATH="$PATH:$HOME/.local/bin"` — note this is what makes pip `--user` tools
  (`konsave`, `speedtest-cli`) reachable. Comment says origin was Konsave.

## Custom aliases (`custom/aliases.zsh`)

| Alias | Expands to |
|-------|-----------|
| `ll` / `la` | `ls -l` / `ls -a` |
| `ff` | `fastfetch` |
| `v` | `nvim` |
| `sv` | `sudoedit` (with `SUDO_EDITOR=/usr/bin/zsh`) |
| `dp` / `dpy` | `sudo dnf install` / `... -y` |
| `upd` | `sudo dnf upgrade -y; dnf autoremove -y; needs-reboot` |
| `needs-reboot` | `needs-restarting -r ; echo $?` |
| `yeet` | `rm` |
| `FF` | `exit` |

**Joke aliases:** `gay` = `| lolcat`, `matrix` = `cmatrix`, `gay-matrix`,
`steam-locomotive` = `sl`, `gay-locomotive` = `sl | lolcat`. (`cmatrix`/`lolcat`
come from [[role-packages]].)

## Startup banner (`custom/startupcode.zsh`)

On every shell start it prints the ZSH version, runs `fastfetch --pipe false`, `cd`s
home, then prints a German greeting that includes the hardware vendor + model, read
live via `hostnamectl --json short | jq -r '(.HardwareVendor) + " " + (.HardwareModel)'`
(`jq` is installed by [[role-packages]]). Ends with a "have a productive day" line.
This replaced an earlier static `custom/Device.txt` file (hardcoded per-machine, e.g.
`Dell XPS 15 9570`) — that file is no longer read by the banner, though the stow role
still backs it up if present ([[role-dotfiles-stow]]).

> To adapt for a new machine: nothing to edit — `hostnamectl` reports the local
> hardware automatically.
