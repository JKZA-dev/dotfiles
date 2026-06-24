# Role: packages

**Summary:** Installs base packages on every machine and a GUI/desktop layer
(plus Microsoft Edge and Flatpak) only in desktop mode, using `dnf5`, `pip`, and Flatpak.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`ansible/roles/packages/tasks/main.yml`)
**Related:** [[ansible-architecture]], [[desktop-vs-server]], [[role-kde-desktop]], [[testing-molecule]]
**Last updated:** 2026-06-21

---

## Base packages (always installed)

Via `ansible.builtin.dnf5` with `state: present`:

```
zsh  git  stow  curl  zip  btop  fastfetch  neovim
python3-pip  python3-packaging  ninja-build
cmatrix  lolcat  yt-dlp  Tmux
```

Notes:
- `stow` powers [[role-dotfiles-stow]]; `zsh` is made default by the zsh role.
- `cmatrix` + `lolcat` back the joke aliases in [[zsh-configuration]].
- `python3-pip` / `python3-packaging` are needed for the `pip`-installed tools below
  and for `dnf5` Python bindings.

## Desktop packages (`install_mode == 'desktop'`)

```
gimp  kicad  plasma-browser-integration  applet-window-buttons
```

## Microsoft Edge (desktop only)

Three tasks: stat-check whether `/etc/yum.repos.d/microsoft-edge.repo` exists, add
the repo via `yum_repository` (with Microsoft GPG key) if not, then install
`microsoft-edge-stable`. The stat guard keeps the repo-add idempotent.

## pip tools

- **`speedtest-cli`** — installed `--user` on **every** machine (not gated).
- (`konsave` is also pip-installed, but by [[role-kde-desktop]], not here.)

## Flatpak (desktop only)

Adds the **Flathub** remote (`community.general.flatpak_remote`, system method) and
installs desktop flatpaks (`community.general.flatpak`). ⚠️ The flatpak list is
currently a **placeholder** (`com.example.App`) — replace before relying on it.

## Idempotency

`state: present` and the Edge repo stat-guard mean re-runs report no changes, which
[[testing-molecule]] enforces via its idempotency step.
