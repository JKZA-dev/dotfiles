# ZSH Configuration

**Summary:** The shell is ZSH + Oh-My-Zsh with the Powerlevel10k theme; the repo
bundles the whole Oh-My-Zsh tree and adds custom aliases plus a themed startup banner.
The config is **OS-neutral**: the same files run on Fedora and macOS, with the
differences isolated in `custom/bin/device-model.sh` and an `$OSTYPE` switch in
`custom/aliases.zsh`.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`zsh/.zshrc`, `custom/aliases.zsh`, `custom/startupcode.zsh`, `custom/bin/device-model.sh`)
**Related:** [[role-dotfiles-stow]], [[ansible-architecture]], [[role-packages]], [[neovim-configuration]], [[fastfetch-configuration]], [[ci-github-actions]]
**Last updated:** 2026-09-13

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

Split into an OS-neutral part and a `case "$OSTYPE"` switch (`linux*` / `darwin*`), so
the same file works on Fedora and macOS.

**Always defined:**

| Alias | Expands to |
|-------|-----------|
| `ll` / `la` | `ls -l` / `ls -a` |
| `ff` | `fastfetch` |
| `v` | `nvim` |
| `sv` | `sudoedit` |
| `yeet` | `rm` |
| `FF` | `exit` |

`SUDO_EDITOR` is exported as `$(command -v nvim)` — resolved at load time, so it works
with Fedora's `/usr/bin/nvim` as well as Homebrew's `/opt/homebrew/bin/nvim`, and is
simply left unset when nvim is absent. (It previously pointed at `/usr/bin/zsh`, which
contradicted its own comment and does not exist on macOS.)

**Package manager, per OS:**

| Alias | `linux*` | `darwin*` |
|-------|----------|-----------|
| `dp` | `sudo dnf install` | `brew install` |
| `dpy` | `sudo dnf install -y` | `brew install` (brew does not prompt) |
| `upd` | `sudo dnf upgrade -y; dnf autoremove -y; needs-reboot` | `brew update && brew upgrade && brew cleanup` |
| `needs-reboot` | `needs-restarting -r ; echo $?` | *not defined — no macOS equivalent* |

**Joke aliases:** `gay` = `| lolcat`, `matrix` = `cmatrix`, `gay-matrix`,
`steam-locomotive` = `sl`, `gay-locomotive` = `sl | lolcat`. (`cmatrix`/`lolcat`
come from [[role-packages]].)

## Startup banner (`custom/startupcode.zsh`)

On every shell start it prints the ZSH version, runs `fastfetch --pipe false` (guarded
by `command -v`, so a machine without fastfetch does not produce an error), `cd`s home,
then prints a German greeting that includes the hardware vendor + model, and ends with
a "have a productive day" line.

The device line is produced by **`custom/bin/device-model.sh`**, called as
`"${ZSH_CUSTOM:-$ZSH/custom}/bin/device-model.sh"`. The banner itself contains no
OS-specific code, so the identical config works on Fedora and macOS.

### `custom/bin/device-model.sh`

Prints `"Vendor Model"` for the current machine. POSIX-ish bash, written against
**bash 3.2** because that is what macOS ships.

Detection chain:

| OS | Source |
|----|--------|
| Darwin | `system_profiler SPHardwareDataType` (Model Name) + `sysctl -n hw.model` (Model ID) → `Apple MacBook Pro (Mac16,1)` |
| Linux | 1. `hostnamectl` (text-parsed, **no `jq` needed**) · 2. `/sys/class/dmi/id/*` (systemd-less containers) · 3. devicetree (ARM boards, e.g. Raspberry Pi) |
| any | fallback `uname -s` + `uname -m`, e.g. `Linux x86_64` — never an empty line |

Helpers filter mainboard placeholders (`To be filled by O.E.M.`, `System Product Name`,
…) and avoid vendor duplication (`LENOVO` + `Lenovo ThinkPad X1` → printed once).

**Caching:** the result is written to `${XDG_CACHE_HOME:-$HOME/.cache}/device-model`
— roughly 150 ms uncached vs. 7 ms cached. Cache writes are failure-tolerant (a
read-only `$HOME` just means re-detecting each time). The cache deliberately lives
outside the repo: unlike the old `custom/Device.txt`, a per-machine value must not be
synced between machines. Flags: `--refresh`, `--no-cache`, `--help`.

This chain replaced the earlier `hostnamectl --json short | jq …` one-liner, which was
systemd-only and failed on macOS. That one-liner had in turn replaced a static
`custom/Device.txt` (hardcoded per-machine, e.g. `Dell XPS 15 9570`); **that file has
now been deleted** and dropped from the stow role's backup loop
([[role-dotfiles-stow]]).

The script is covered by the `shellcheck` step in CI ([[ci-github-actions]]).

> To adapt for a new machine: nothing to edit — the script reports the local hardware
> automatically. After a hardware swap, run it once with `--refresh`.
