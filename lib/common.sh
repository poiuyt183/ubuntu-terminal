# Shared helpers for the install steps. Sourced, never executed directly.

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BIN="$HOME/.local/bin"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup}"

# shellcheck disable=SC1090
set -a; . "$DOTFILES/versions.env"; set +a

if [ -t 1 ]; then
  C_INFO=$'\033[1;34m'; C_OK=$'\033[1;32m'; C_WARN=$'\033[1;33m'
  C_ERR=$'\033[1;31m';  C_OFF=$'\033[0m'
else
  C_INFO=; C_OK=; C_WARN=; C_ERR=; C_OFF=
fi

info() { printf '%s==>%s %s\n' "$C_INFO" "$C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_OK"  "$C_OFF" "$*"; }
warn() { printf '%swarn%s %s\n' "$C_WARN" "$C_OFF" "$*" >&2; }
die()  { printf '%serr %s %s\n' "$C_ERR" "$C_OFF" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Skip work that's already done unless FORCE=1.
# usage: installed <name> <binary> <expected-version-substring>
installed() {
  [ "${FORCE:-0}" = 1 ] && return 1
  local bin=$2 want=$3
  have "$bin" || return 1
  [ -z "$want" ] && { ok "$1 already installed"; return 0; }
  if "$bin" --version 2>&1 | grep -qF "$want"; then
    ok "$1 $want already installed"; return 0
  fi
  return 1
}

fetch() { curl -fsSL --retry 3 --proto '=https' --tlsv1.2 "$1" -o "$2"; }

# Download a tar archive and copy one binary out of it into ~/.local/bin.
# usage: install_tar_bin <name> <url> <path-inside-archive>
install_tar_bin() {
  local name=$1 url=$2 inner=$3 tmp
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' RETURN
  info "installing $name"
  fetch "$url" "$tmp/a.tar.gz" || die "download failed: $url"
  tar -xf "$tmp/a.tar.gz" -C "$tmp" || die "extract failed: $name"
  install -Dm755 "$tmp/$inner" "$BIN/$name" || die "no $inner in $name archive"
  ok "$name -> $BIN/$name"
}

# Symlink a repo file into place, backing up whatever is already there.
# usage: link <repo-relative-src> <absolute-dst>
link() {
  local src="$DOTFILES/$1" dst=$2
  [ -e "$src" ] || die "missing in repo: $1"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    ok "$dst"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$(basename "$dst").$(date +%Y%m%d-%H%M%S)"
    warn "backed up existing $dst to $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "$dst -> $src"
}
