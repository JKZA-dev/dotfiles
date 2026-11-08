# Overview

Ansible-managed dotfiles for Fedora and macOS. One script, [[bootstrap-installation]], installs prerequisites, syncs the repo and runs `ansible/setup.yml`.

| Layer | Location | Details |
|---|---|---|
| Provisioning | `ansible/` | [[ansible-architecture]] |
| Files in `$HOME` | `stow/` | [[role-dotfiles-stow]] |
| Third-party code | `vendor/` submodules | [[zsh-configuration]], [[role-kde-desktop]] |
| KDE desktop state | `kde/profile/` | [[role-kde-desktop]] |

Behaviour varies along two axes, described in [[desktop-vs-server]]: the mode and the operating system.

Large files: wallpapers in `stow/backgrounds/` use Git LFS. The older blobs remain in Git history until it is rewritten with `git lfs migrate`.
