# Fastfetch Configuration

**Summary:** A custom `config.jsonc` defines the fastfetch module list (including a
custom "OS_Age" command); fastfetch runs at every shell start and has an `ff` alias.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`fastfetch/.config/fastfetch/config.jsonc`)
**Related:** [[role-dotfiles-stow]], [[zsh-configuration]], [[role-kde-desktop]]
**Last updated:** 2026-06-21

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
system in days from the root filesystem birth time:

```sh
birth_install=$(stat -c %W /); current=$(date +%s);
time_progression=$((current - birth_install));
days_difference=$((time_progression / 86399)); echo $days_difference days
```

(Divides by 86399 rather than 86400 — a near-day approximation.)

## Related: KDE splash

Not part of the fastfetch config itself, but the repo also ships a third-party
fastfetch-styled KDE Plasma splash screen — documented under [[role-kde-desktop]].
