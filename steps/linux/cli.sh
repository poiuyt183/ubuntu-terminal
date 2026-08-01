#!/usr/bin/env bash
# Standalone CLI binaries into ~/.local/bin — newer than Ubuntu's packages and
# independent of apt. Versions are pinned in versions.env.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

mkdir -p "$BIN"

installed ripgrep rg "$RIPGREP_VERSION" || install_tar_bin rg \
  "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  "ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg"

installed fd fd "$FD_VERSION" || install_tar_bin fd \
  "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  "fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd"

installed bat bat "$BAT_VERSION" || install_tar_bin bat \
  "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  "bat-v${BAT_VERSION}-x86_64-unknown-linux-musl/bat"

installed delta delta "$DELTA_VERSION" || install_tar_bin delta \
  "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  "delta-${DELTA_VERSION}-x86_64-unknown-linux-musl/delta"

installed zoxide zoxide "$ZOXIDE_VERSION" || install_tar_bin zoxide \
  "https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  "zoxide"

installed starship starship "${STARSHIP_VERSION#v}" || install_tar_bin starship \
  "https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-x86_64-unknown-linux-musl.tar.gz" \
  "starship"

installed eza eza "${EZA_VERSION#v}" || install_tar_bin eza \
  "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" \
  "./eza"

# fzf: just the binary — .bashrc gets the Ctrl-R / Ctrl-T / Alt-C bindings from
# `fzf --bash`, so there's no need to clone the repo for its shell/ scripts.
installed fzf fzf "${FZF_VERSION#v}" || install_tar_bin fzf \
  "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-linux_amd64.tar.gz" \
  "fzf"

# tree-sitter CLI: needed by nvim-treesitter's `main` branch to build parsers.
if ! installed tree-sitter tree-sitter "${TREE_SITTER_VERSION#v}"; then
  info "installing tree-sitter"
  tmp=$(mktemp -d)
  fetch "https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/tree-sitter-linux-x64.gz" "$tmp/ts.gz"
  gunzip -c "$tmp/ts.gz" > "$tmp/tree-sitter"
  place "$tmp/tree-sitter" "$BIN/tree-sitter"
  rm -rf "$tmp"
  ok "tree-sitter -> $BIN/tree-sitter"
fi

# zig: used as the C compiler for treesitter parsers when there is no system
# gcc. Harmless to have alongside gcc.
if [ "$("$HOME/.local/zig/zig" version 2>/dev/null)" != "$ZIG_VERSION" ]; then
  info "installing zig $ZIG_VERSION"
  tmp=$(mktemp -d)
  fetch "https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz" "$tmp/zig.tar.xz"
  tar -xf "$tmp/zig.tar.xz" -C "$tmp"
  rm -rf "$HOME/.local/zig"
  mv "$tmp/zig-x86_64-linux-${ZIG_VERSION}" "$HOME/.local/zig"
  rm -rf "$tmp"
  ok "zig -> ~/.local/zig"
else
  ok "zig $ZIG_VERSION already installed"
fi
ln -sf "$HOME/.local/zig/zig" "$BIN/zig"

# The `cc` shim only makes sense when the system has no real C compiler --
# ~/.local/bin comes first on PATH and would otherwise shadow /usr/bin/cc.
if [ -x /usr/bin/cc ] || [ -x /usr/bin/gcc ]; then
  [ -L "$BIN/cc" ] && rm -f "$BIN/cc"
  ok "system C compiler present, skipping zig cc shim"
else
  place "$DOTFILES/bin/cc" "$BIN/cc"
  ok "installed zig cc shim -> $BIN/cc"
fi

ok "CLI tools done"
