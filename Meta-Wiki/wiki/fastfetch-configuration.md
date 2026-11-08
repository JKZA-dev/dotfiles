# fastfetch

`stow/fastfetch/.config/fastfetch/config.jsonc` lists the modules. The custom `OS_Age` module derives the age from the birth time of `/` (`stat -f %B` on macOS, `stat -c %W` on Linux) and prints `n/a` if the filesystem does not record one.

Runs in the startup banner ([[zsh-configuration]]) and feeds the KDE splash ([[role-kde-desktop]]).
