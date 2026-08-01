#!/usr/bin/env bash
# Ghostty configuration — the Mac counterpart to the GNOME Terminal dconf load.
#
# Ghostty reads ~/.config/ghostty/config on macOS as well as Linux, so the file
# is simply symlinked out of the repo like every other config.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

link terminal/ghostty/config "$HOME/.config/ghostty/config"

if [ ! -d /Applications/Ghostty.app ]; then
  warn "Ghostty.app not found — run ./install.sh packages (or: brew install --cask ghostty)"
  exit 0
fi

# Ghostty reloads config on launch; a running instance needs cmd-shift-, .
ok "Ghostty configured — relaunch it (or press ⌘⇧, to reload) to apply"
