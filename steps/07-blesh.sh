#!/usr/bin/env bash
# ble.sh — fish-style inline autosuggestions and syntax highlighting in bash.
# Only nightly tarballs are published; there is no stable release to pin.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if [ -f "$HOME/.local/share/blesh/ble.sh" ] && [ "${FORCE:-0}" != 1 ]; then
  ok "ble.sh already installed (re-run with FORCE=1 to update)"
  exit 0
fi

info "installing ble.sh (nightly)"
tmp=$(mktemp -d)
fetch "https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz" "$tmp/ble.tar.xz"
tar -xf "$tmp/ble.tar.xz" -C "$tmp"
src=$(find "$tmp" -maxdepth 1 -type d -name 'ble-nightly*' | head -1)
[ -n "$src" ] || die "unexpected ble.sh archive layout"
mkdir -p "$HOME/.local/share"
rm -rf "$HOME/.local/share/blesh"
mv "$src" "$HOME/.local/share/blesh"
rm -rf "$tmp"
ok "ble.sh -> ~/.local/share/blesh"
