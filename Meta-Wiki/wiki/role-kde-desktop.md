# Roles: kde and macos

## kde (Fedora desktop)
**Profile.** `kde/profile/` is an unpacked konsave export, so changes are diffable. Paths use the placeholder `__HOME__`. The role copies it to a temporary directory, inserts the home directory, zips it as `<profile>.knsv` and runs `konsave -i`. `konsave -a` runs only with `kde_apply_profile: true`. Plasmoids such as window title ship inside the profile.

To capture the current desktop, run `scripts/kde-export.sh` on the Fedora machine and commit the result. The script also enforces the splash theme and the Konsole font.

**Splash.** `vendor/fastfetch-kde-splash` is copied to `~/.local/share/plasma/look-and-feel/fastfetch-splash`. `Splash.qml` is written with the values from `kde_splash` (color, layout, background), the same substitutions upstream's interactive `install.sh` makes.

## macos (macOS desktop)
Imports `macos/Pro.terminal` into `com.apple.Terminal` and makes it the default and startup profile. `import-terminal-profile.js` rebuilds the background bookmark, which is machine-specific, from `macos_terminal_wallpaper`. Quit Terminal before the import, otherwise it can overwrite the settings when it exits.
