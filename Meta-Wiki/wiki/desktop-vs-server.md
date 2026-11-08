# Modes and platforms

Two independent axes select what gets installed.

**Mode**, from `install_mode` and `gaming`: package groups `base`, `desktop`, `desktop_heavy`, `gaming`. Server uses `base` only. Gaming requires desktop.

**Platform**, from `ansible_facts.distribution`: `vars/Fedora.yml` or `vars/MacOSX.yml`, both with the same keys, see [[role-packages]].

| Feature | Fedora server | Fedora desktop | macOS server | macOS desktop |
|---|:-:|:-:|:-:|:-:|
| zsh, CLI tools, SSH | ✅ | ✅ | ✅ | ✅ |
| Neovim with Java tooling | Without | ✅ | Without | ✅ |
| Wallpapers | ❌ | ✅ | ❌ | ✅ |
| Apps | ❌ | Flatpak | ❌ | Casks |
| KDE profile, splash | ❌ | ✅ | ❌ | ❌ |
| Terminal profile | ❌ | ❌ | ❌ | ✅ |

The `kde` and `macos` roles are selected in `setup.yml`.
