#!/usr/bin/env bash
# nvm + the current Node LTS.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  info "installing nvm $NVM_VERSION"
  # -u NODE_VERSION: nvm's installer treats that variable as "also install this
  #   version" and reports a bogus failure for an alias like --lts.
  # PROFILE=/dev/null: our .bashrc already sources nvm; don't let it append.
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
    | env -u NODE_VERSION PROFILE=/dev/null bash
else
  ok "nvm already installed"
fi

# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

info "installing node ($NODE_TARGET)"
nvm install "$NODE_TARGET"          # no-op when already present
nvm alias default 'lts/*' >/dev/null

nvm use default >/dev/null
ok "node $(node --version) / npm $(npm --version) ready"
