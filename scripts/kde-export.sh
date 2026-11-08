#!/usr/bin/env bash
# Saves the current KDE desktop into kde/profile/ (diffable, user-independent).
set -euo pipefail

readonly PROFILE=JKZA-KDE-Workstation
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly TARGET=$REPO/kde/profile

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

konsave -s "$PROFILE" -f
konsave -e "$PROFILE" -d "$tmp" -n profile -f

rm -rf "$TARGET"
mkdir -p "$TARGET"
unzip -q "$tmp/profile.knsv" -d "$TARGET"

# Installed from vendor/fastfetch-kde-splash by the kde role.
rm -rf "$TARGET/export/share_folder/plasma/look-and-feel/fastfetch-splash"

# Not captured reliably by the desktop state.
sed -i 's/^Theme=.*/Theme=fastfetch-splash/' "$TARGET/save/configs/ksplashrc"
sed -i 's/^Font=[^,]*/Font=JetBrainsMono Nerd Font/' "$TARGET"/export/share_folder/konsole/*.profile

grep -rlIF "$HOME" "$TARGET" | while read -r file; do
    sed -i "s|$HOME|__HOME__|g" "$file"
done

echo "Exported to $TARGET. Review with: git diff --stat -- kde/profile"
