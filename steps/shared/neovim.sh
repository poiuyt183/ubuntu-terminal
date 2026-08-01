#!/usr/bin/env bash
# Neovim from the official tarball rather than the OS package manager, so both
# machines run the exact same version — this config needs 0.11+ APIs such as
# vim.lsp.config and vim.diagnostic.jump, and the plugin lockfile is only
# guaranteed against the pinned release.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

if ! installed neovim nvim "$NVIM_VERSION"; then
  # $NVIM_ASSET is nvim-linux-x86_64 or nvim-macos-arm64 (set in common.sh).
  install_tar_dir "neovim $NVIM_VERSION" \
    "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ASSET}.tar.gz" \
    "$NVIM_ASSET" "$HOME/.local/nvim"
  mkdir -p "$BIN"
  ln -sf "$HOME/.local/nvim/bin/nvim" "$BIN/nvim"
  ok "nvim -> $BIN/nvim"
fi

# Plugins: lazy.nvim bootstraps itself on first launch and restores the exact
# commits recorded in config/nvim/lazy-lock.json. Headless so it can run
# unattended; treesitter parsers compile here, which is the slow part.
if [ "${SKIP_NVIM_SYNC:-0}" != 1 ]; then
  info "syncing neovim plugins (this compiles treesitter parsers, ~1-3 min)"
  "$BIN/nvim" --headless "+Lazy! restore" +qa 2>&1 | tail -5 || \
    warn "plugin sync reported errors — open nvim and run :Lazy / :checkhealth"
  ok "neovim plugins synced"
fi
