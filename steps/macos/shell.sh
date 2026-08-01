#!/usr/bin/env bash
# Make Homebrew's bash 5 the login shell.
#
# Why: macOS still ships bash 3.2 (a 2007 release, kept for licensing reasons).
# ble.sh needs 4.0+, and so do parts of the shared .bashrc. Switching means the
# Mac and the Linux box run byte-identical shell config.
#
# Set SKIP_CHSH=1 to install bash 5 but leave the login shell alone.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

BREW_BASH="$HOMEBREW_PREFIX/bin/bash"
[ -x "$BREW_BASH" ] || die "$BREW_BASH missing — run ./install.sh packages first"

ok "bash $("$BREW_BASH" -c 'echo $BASH_VERSION')"

if [ "${SKIP_CHSH:-0}" = 1 ]; then
  warn "SKIP_CHSH=1 — leaving the login shell as $SHELL"
  exit 0
fi

# chsh refuses any shell that isn't listed in /etc/shells.
if ! grep -qxF "$BREW_BASH" /etc/shells; then
  info "adding $BREW_BASH to /etc/shells (needs sudo)"
  echo "$BREW_BASH" | sudo tee -a /etc/shells >/dev/null
fi

current=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
if [ "$current" = "$BREW_BASH" ]; then
  ok "login shell is already $BREW_BASH"
else
  info "changing login shell (macOS will ask for your password)"
  chsh -s "$BREW_BASH"
  ok "login shell -> $BREW_BASH (takes effect in new terminal windows)"
fi

# Login shells read ~/.bash_profile and only fall back to ~/.profile when it is
# absent. The link step points both at the same file so the order can't matter.
