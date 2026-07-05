# Role: packages

**Summary:** Installs base packages on every machine and a GUI/desktop layer
(plus Microsoft Edge and Flatpak) only in desktop mode, using `dnf5`, `pip`, and Flatpak.
The heavy/flaky desktop bits are skipped under `molecule_test` to keep CI fast.

**Sources:** `raw/2026-06-21-dotfiles-repo-snapshot.md` (`ansible/roles/packages/tasks/main.yml`)
**Related:** [[ansible-architecture]], [[desktop-vs-server]], [[role-kde-desktop]], [[testing-molecule]]
**Last updated:** 2026-06-29

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

Split into two dnf5 tasks:

- **Base (also runs in CI):** `gimp` — the representative GUI package proving the
  desktop branch installs something ([[testing-molecule]] asserts it).
- **Heavy (skipped under `molecule_test`):** `kicad`, `plasma-browser-integration`,
  `applet-window-buttons`.

## Microsoft Edge (desktop only, not in CI)

Three tasks: stat-check whether `/etc/yum.repos.d/microsoft-edge.repo` exists, add
the repo via `yum_repository` (with Microsoft GPG key) if not, then install
`microsoft-edge-stable`. The stat guard keeps the repo-add idempotent. All three are
gated `not molecule_test` (external proprietary repo — flaky/heavy in containers).

## pip tools

- **`speedtest-cli`** — installed on **every** machine with
  `--user --break-system-packages` (Fedora's system Python is externally-managed,
  PEP 668, so plain `--user` is refused).
- (`konsave` is also pip-installed, but by [[role-kde-desktop]], not here.)

## Flatpak (desktop only, not in CI)

Adds the **Flathub** remote (`community.general.flatpak_remote`, system method) and
installs desktop flatpaks (`community.general.flatpak`), gated `not molecule_test`
(the module needs the `flatpak` binary). Current app list:

```
org.prismlauncher.PrismLauncher   # Prism Minecraft Launcher
im.riot.Riot                      # Element (Matrix client)
com.github.tchx84.Flatseal        # Flatseal (Flatpak permissions)
com.ktechpit.whatsie              # Whatsie (WhatsApp client)
com.discordapp.Discord            # Discord
```

(The old `com.example.App` placeholder — which broke every desktop run — is gone.)

## Idempotency

`state: present`, the Edge repo stat-guard, and `--break-system-packages` pip mean
re-runs report no changes, which [[testing-molecule]] enforces via its idempotency
step. The heavy/Edge/Flatpak tasks are skipped in containers anyway.
