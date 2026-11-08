# Role: packages

`tasks/main.yml` loads `vars/<distribution>.yml`, computes `packages_groups` once, then includes `tasks/<distribution>.yml`.

```yaml
packages_native: { base, desktop, desktop_heavy, gaming } # dnf or Homebrew formulae
packages_apps:   { base, desktop, desktop_heavy, gaming } # Flatpak or casks
```

## Fedora
Enables RPM Fusion free and nonfree and the Fedora third-party repositories, installs everything in one `dnf5` transaction, adds Flathub and its apps, and unpacks JetBrains Mono Nerd Font into `~/.local/share/fonts`. Steam comes from RPM Fusion nonfree. Microsoft Edge remains as a commented-out entry.

## macOS
Homebrew formulae and casks, without `become`.

## Toggles
`packages_heavy`, `packages_flatpak`, `packages_rpmfusion`, see `defaults/main.yml`.
