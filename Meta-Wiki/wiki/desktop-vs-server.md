# Desktop vs Server Modes

**Summary:** A single `install_mode` variable (`desktop` or `server`) decides whether
GUI packages, wallpapers, and the KDE profile are installed on top of the shared base.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`README.md`, `ansible/setup.yml`, `roles/packages`)
**Related:** [[overview]], [[ansible-architecture]], [[bootstrap-installation]], [[role-packages]], [[role-kde-desktop]]
**Last updated:** 2026-07-13

---

## Capability matrix

| | Desktop (KDE) | Server |
|---|:---:|:---:|
| Base packages (zsh, neovim, btop, ...) | ✅ | ✅ |
| ZSH + Oh-My-Zsh + Powerlevel10k | ✅ | ✅ |
| Dotfiles via Stow (nvim, fastfetch, zsh) | ✅ | ✅ |
| SSH files | ✅ | ✅ |
| GUI packages (gimp, kicad, Edge) | ✅ | ❌ |
| Wallpapers | ✅ | ❌ |
| KDE Konsave profile | ✅ | ❌ |

## How the switch works

`install_mode` is chosen interactively by [[bootstrap-installation]] and passed as
`--extra-vars "install_mode=..."`. It defaults to `desktop` if unset.

- **Role-level gating** ([[ansible-architecture]]): `backgrounds` and `kde` roles
  carry `when: install_mode == 'desktop'`.
- **Task-level gating** ([[role-packages]]): desktop packages, Microsoft Edge repo,
  and Flatpak tasks all carry `when: install_mode == 'desktop'`.

## Gaming-Ready — an orthogonal opt-in

Independent of `install_mode`, [[bootstrap-installation]] additionally asks
desktop installs whether to enable **Gaming-Ready** (`game_ready` var, default
`false`), which installs Steam + Prism Launcher on top of the normal desktop set.
It has no server-mode equivalent — the question is skipped entirely outside
desktop mode. See [[role-packages]].

## What "server" deliberately omits

Verified by [[testing-molecule]]: in server mode, `gimp`, `kicad`, and
`plasma-browser-integration` must **not** be present. The server profile is a clean
terminal environment — same shell and dotfiles, no GUI footprint.
