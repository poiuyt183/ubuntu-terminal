#!/usr/bin/env bash
# GNOME Terminal profile: Catppuccin Mocha palette, JetBrains Mono 12.
#
# This overwrites the default profile's colours and font. Skipped automatically
# when there is no dconf (server / non-GNOME machine).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! have dconf; then
  warn "dconf not found — skipping terminal theme (apt install dconf-cli)"
  exit 0
fi
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  warn "no D-Bus session — run this step from a desktop terminal to theme it"
  exit 0
fi

info "backing up current terminal settings to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
dconf dump /org/gnome/terminal/ > "$BACKUP_DIR/gnome-terminal.$(date +%Y%m%d-%H%M%S).dconf" || true

info "applying GNOME Terminal profile"
dconf load /org/gnome/terminal/ < "$DOTFILES/terminal/gnome-terminal.dconf"
ok "terminal theme applied (reopen the terminal to see it)"
