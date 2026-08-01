# Shared helpers for the install steps. Sourced, never executed directly.
#
# Kept compatible with bash 3.2, because on a fresh macOS the very first run
# happens under Apple's ancient system bash — before Homebrew's bash 5 exists.
# That rules out associative arrays and ${var,,}.

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BIN="$HOME/.local/bin"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup}"

# ── Platform ────────────────────────────────────────────────────────────────
case "$(uname -s)" in
  Linux)  OS=linux ;;
  Darwin) OS=macos ;;
  *)      echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) ARCH=x86_64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Release-asset naming for the two upstreams we download directly.
if [ "$OS" = macos ]; then
  GO_PLATFORM="darwin-$( [ "$ARCH" = arm64 ] && echo arm64 || echo amd64 )"
  NVIM_ASSET="nvim-macos-${ARCH}"
  HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$( [ "$ARCH" = arm64 ] && echo /opt/homebrew || echo /usr/local )}"
  export HOMEBREW_PREFIX
else
  GO_PLATFORM="linux-$( [ "$ARCH" = arm64 ] && echo arm64 || echo amd64 )"
  NVIM_ASSET="nvim-linux-${ARCH}"
fi

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

# Copy a file into place with a mode. BSD install has no -D, so create the
# parent directory separately rather than relying on it.
place() { # <src> <dst> [mode]
  mkdir -p "$(dirname "$2")"
  cp -f "$1" "$2"
  chmod "${3:-755}" "$2"
}

# Download a tar archive and copy one binary out of it into ~/.local/bin.
# usage: install_tar_bin <name> <url> <path-inside-archive>
install_tar_bin() {
  local name=$1 url=$2 inner=$3 tmp
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' RETURN
  info "installing $name"
  fetch "$url" "$tmp/a.tar.gz" || die "download failed: $url"
  tar -xf "$tmp/a.tar.gz" -C "$tmp" || die "extract failed: $name"
  [ -f "$tmp/$inner" ] || die "no $inner in $name archive"
  place "$tmp/$inner" "$BIN/$name"
  ok "$name -> $BIN/$name"
}

# Download a tarball and replace a whole directory with its single top-level
# folder. Used for the Neovim and Go toolchains.
# usage: install_tar_dir <name> <url> <top-level-dir-in-archive> <dest>
install_tar_dir() {
  local name=$1 url=$2 inner=$3 dest=$4 tmp
  tmp=$(mktemp -d)
  info "installing $name"
  fetch "$url" "$tmp/a.tar.gz" || { rm -rf "$tmp"; die "download failed: $url"; }
  tar -xf "$tmp/a.tar.gz" -C "$tmp" || { rm -rf "$tmp"; die "extract failed: $name"; }
  [ -d "$tmp/$inner" ] || { rm -rf "$tmp"; die "no $inner/ in $name archive"; }
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  mv "$tmp/$inner" "$dest"
  rm -rf "$tmp"
  ok "$name -> $dest"
}

# Symlink a repo file into place, backing up whatever is already there.
# usage: link <repo-relative-src> <absolute-dst>
link() {
  local src="$DOTFILES/$1" dst=$2
  [ -e "$src" ] || die "missing in repo: $1"
  # Plain readlink, not readlink -f: BSD readlink lacks -f on older macOS, and
  # we always create these links with the exact $src path anyway.
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
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
