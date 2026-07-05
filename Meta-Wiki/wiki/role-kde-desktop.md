# Role: kde & backgrounds (Desktop)

**Summary:** Desktop-only roles that copy the Hacknet wallpapers and import/apply the
KDE Plasma profile via Konsave; both are skipped in server mode and in containers.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`roles/kde/tasks/main.yml`, `roles/backgrounds/tasks/main.yml`, `konsave/`, `fastfetch-Splashscreen/.../metadata.json`)
**Related:** [[ansible-architecture]], [[desktop-vs-server]], [[fastfetch-configuration]]
**Last updated:** 2026-06-21

---

## When these run

Both roles carry `when: install_mode == 'desktop' and not molecule_test`. So they run
only on real desktops, never on servers or inside Molecule containers (KDE needs a
live Plasma session and uses interactive prompts — see [[testing-molecule]]).

## backgrounds role

1. Create `~/Pictures/Hacknet/` (mode `0755`).
2. Copy the Hacknet wallpaper set from `Backgrounds/Pictures/Hacknet/` into it
   (`remote_src: true`, mode `0644`).

The wallpapers are the "Hacknet" game art set (e.g. Starfield, Floatvoid, Miami,
riptide). KDE then finds them as wallpaper options.

## kde role — Konsave profile

[Konsave](https://github.com/Prayag2/konsave) saves/restores a full KDE Plasma config
(theme, icons, panels, widgets, colors) as a single `.knsv` archive. The profile here
is `konsave/JKZA-KDE-Workstation.knsv`.

Task flow:
1. **Install Konsave** via `pip --user`.
2. **List imported profiles** (`konsave -l`, `changed_when: false`, `ignore_errors`).
3. **Import** `JKZA-KDE-Workstation.knsv` — only if not already imported (checks the
   list output / non-zero rc).
4. **Interactive `pause`** — asks `Apply profile now? (y/n)`. Applying overwrites the
   current KDE layout and requires a re-login.
5. **Apply** (`konsave -a JKZA-KDE-Workstation`) if the answer was yes; otherwise a
   debug message tells you how to apply it manually later.

Konsave binary is invoked at `~/.local/bin/konsave` (the pip `--user` install path,
added to `PATH` in [[zsh-configuration]]).

## Related: Fastfetch KDE splash screen

`fastfetch-Splashscreen/fastfetch-splash/` is a **third-party** Plasma Look-and-Feel
splash package (`fastfetch-splash` v1.5, MIT, by *herzane*) that shows a fastfetch-style
splash. It is bundled in the repo but not wired into any Ansible role — installed
manually via its own `install.sh` if desired. See also [[fastfetch-configuration]].
