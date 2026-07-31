#!/usr/bin/env bash
# uv, a uv-managed CPython, and the Python CLIs installed as isolated tools.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

export PATH="$BIN:$PATH"

if ! installed uv uv "$UV_VERSION"; then
  info "installing uv $UV_VERSION"
  curl -fsSL "https://astral.sh/uv/${UV_VERSION}/install.sh" | \
    env UV_INSTALL_DIR="$BIN" INSTALLER_NO_MODIFY_PATH=1 sh
  ok "uv -> $BIN/uv"
fi

info "installing python $UV_PYTHON_VERSION"
uv python install "$UV_PYTHON_VERSION"

for t in $PY_TOOLS; do
  if [ "${FORCE:-0}" != 1 ] && uv tool list 2>/dev/null | grep -q "^$t "; then
    ok "$t already installed"
    continue
  fi
  info "uv tool install $t"
  uv tool install "$t" || warn "failed: $t"
done

# uv puts tool shims in ~/.local/bin, which .bashrc already has on PATH.
uv tool update-shell >/dev/null 2>&1 || true
ok "python tooling done"
