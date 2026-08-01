#!/usr/bin/env bash
# Homebrew + everything in macos/Brewfile (CLI tools, fonts, Ghostty).
#
# Runs under Apple's bash 3.2 on a fresh machine — keep it 3.2 compatible.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# The Xcode Command Line Tools give us git and clang; Homebrew's installer
# pulls them in itself, which is why this check comes first but doesn't block.
if ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode Command Line Tools missing — Homebrew will install them (GUI prompt)"
fi

if ! have brew; then
  info "installing Homebrew (asks for your password)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  ok "homebrew already installed"
fi

# A fresh install isn't on PATH yet in this non-interactive shell.
if ! have brew; then
  [ -x "$HOMEBREW_PREFIX/bin/brew" ] || die "brew not found at $HOMEBREW_PREFIX/bin/brew"
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi

info "brew bundle (this is the slow part on a fresh machine)"
brew bundle --file="$DOTFILES/macos/Brewfile"

ok "packages done"
