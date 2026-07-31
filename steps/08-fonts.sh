#!/usr/bin/env bash
# JetBrainsMono Nerd Font + the symbols-only fallback font.
#
# The terminal is configured to use plain "JetBrains Mono" (the apt package);
# the Symbols Nerd Font fallback is what actually draws the icons in eza,
# starship, lualine and neo-tree. The fontconfig rule that wires that fallback
# up lives in this repo.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

FONT_DIR="$HOME/.local/share/fonts"

install_font() { # <archive-name> <target-subdir>
  local archive=$1 dir="$FONT_DIR/$2"
  if [ -d "$dir" ] && [ "${FORCE:-0}" != 1 ]; then
    ok "$2 already installed"
    return
  fi
  info "installing $2"
  local tmp; tmp=$(mktemp -d)
  fetch "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${archive}.tar.xz" "$tmp/f.tar.xz"
  mkdir -p "$dir"
  tar -xf "$tmp/f.tar.xz" -C "$dir"
  rm -rf "$tmp"
  ok "$2 -> $dir"
}

install_font JetBrainsMono          JetBrainsMonoNerdFont
install_font NerdFontsSymbolsOnly   NerdFontsSymbolsOnly

# Fallback rule: any monospace font falls back to Symbols Nerd Font for glyphs
# it doesn't have.
mkdir -p "$HOME/.config/fontconfig/conf.d"
ln -sf "$DOTFILES/fontconfig/10-nerd-font-symbols.conf" \
       "$HOME/.config/fontconfig/conf.d/10-nerd-font-symbols.conf"

info "rebuilding font cache"
fc-cache -f >/dev/null
ok "fonts done"
