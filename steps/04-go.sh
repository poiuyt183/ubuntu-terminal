#!/usr/bin/env bash
# Go toolchain into ~/.local/go, Go-based dev tools into ~/go/bin.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

export GOPATH="$HOME/go"
export PATH="$HOME/.local/go/bin:$GOPATH/bin:$PATH"

if [ "$(cat "$HOME/.local/go/VERSION" 2>/dev/null | head -1)" != "go${GO_VERSION}" ]; then
  info "installing go $GO_VERSION"
  tmp=$(mktemp -d)
  fetch "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" "$tmp/go.tar.gz"
  tar -xf "$tmp/go.tar.gz" -C "$tmp"
  rm -rf "$HOME/.local/go"
  mv "$tmp/go" "$HOME/.local/go"
  rm -rf "$tmp"
  ok "go -> ~/.local/go"
else
  ok "go $GO_VERSION already installed"
fi

# GOTOOLCHAIN=auto (the default) lets these fetch a newer compiler when their
# go.mod asks for one, so the pinned Go above doesn't block newer tools.
info "installing go tools into $GOPATH/bin"
tools=(
  "golang.org/x/tools/gopls@${GOPLS_VERSION}"
  "mvdan.cc/gofumpt@${GOFUMPT_VERSION}"
  "github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION}"
  "github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GOLANGCI_LINT_VERSION}"
  "github.com/fatih/gomodifytags@${GOMODIFYTAGS_VERSION}"
  "github.com/josharian/impl@${IMPL_VERSION}"
  "github.com/koron/iferr@${IFERR_VERSION}"
)
for t in "${tools[@]}"; do
  name=${t%@*}; name=${name##*/}
  if [ "${FORCE:-0}" != 1 ] && [ -x "$GOPATH/bin/$name" ]; then
    ok "$name already installed"
    continue
  fi
  info "go install $t"
  go install "$t" || warn "failed: $t"
done

ok "go toolchain done"
