# Fastfetch Configuration

**Summary:** A custom `config.jsonc` defines the fastfetch module list (including a
custom "OS_Age" command); fastfetch runs at every shell start and has an `ff` alias.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`fastfetch/.config/fastfetch/config.jsonc`)
**Related:** [[role-dotfiles-stow]], [[zsh-configuration]], [[role-kde-desktop]]
**Last updated:** 2026-09-13

---

## What it is

Fastfetch is the system-info banner shown on shell startup (`fastfetch --pipe false`
in [[zsh-configuration]]'s startup code) and via the `ff` alias. The package is
installed by [[role-packages]] and the config is stowed as the `fastfetch` package →
`~/.config/fastfetch/` ([[role-dotfiles-stow]]).

## config.jsonc

A JSON-with-comments module list. Standard modules: `title`, `separator`, `os`,
`host`, `kernel`, `uptime`, `packages`, `shell`, `display`, `de`, `wm`, `wmtheme`,
`theme`, `icons`, `font`, `cursor`, `terminal`, `terminalfont`, `cpu`, `gpu`,
`memory`, `swap`, `disk`, `localip`, `battery`, `poweradapter`, `locale`, then
`break` + `colors`.

### Custom module — OS_Age

One custom `command` module (magenta key `OS_Age`) computes the install age of the
system in days from the root filesystem birth time. OS-neutral since 2026-09-13 — the
birth-time flag differs between GNU and BSD `stat`:

```sh
if [ "$(uname -s)" = Darwin ]; then birth_install=$(stat -f %B /);
else birth_install=$(stat -c %W /); fi
current=$(date +%s);
time_progression=$((current - birth_install));
days_difference=$((time_progression / 86399)); echo $days_difference days
```

(Divides by 86399 rather than 86400 — a near-day approximation.)

Previously this always ran `stat -c %W /` (GNU-only). On macOS that call fails, but
because it sits inside `$(...)`, the failure is swallowed and `birth_install` becomes
empty — the arithmetic then silently treats it as `0`, so the module prints a wrong
but plausible-looking number (`current_epoch / 86400`) instead of erroring visibly.
Verified before the fix: reported `20709 days` on a Mac bought in 2024.

## Related: KDE splash

Not part of the fastfetch config itself, but the repo also ships a third-party
fastfetch-styled KDE Plasma splash screen — documented under [[role-kde-desktop]].
