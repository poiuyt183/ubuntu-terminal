#!/usr/bin/env bash
# Symlink the configs into place. Anything already there is moved to
# ~/.dotfiles-backup first, so this is safe to run on a machine that has
# its own dotfiles.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

link home/bashrc     "$HOME/.bashrc"
link home/profile    "$HOME/.profile"
link home/blerc      "$HOME/.blerc"
link home/tmux.conf  "$HOME/.tmux.conf"
link home/gitconfig  "$HOME/.gitconfig"

link config/nvim          "$HOME/.config/nvim"
link config/starship.toml "$HOME/.config/starship.toml"
link config/git/ignore    "$HOME/.config/git/ignore"

# Git identity is per-machine and deliberately untracked.
if [ ! -f "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES/git/gitconfig.local.example" "$HOME/.gitconfig.local"
  warn "created ~/.gitconfig.local — set your name and email in it"
fi

ok "symlinks done"
