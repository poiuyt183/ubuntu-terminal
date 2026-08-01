#!/usr/bin/env bash
#
# Reproduce this terminal setup on a fresh Ubuntu or macOS machine.
#
#   ./install.sh              # everything, in order
#   ./install.sh link         # just re-link the config files
#   ./install.sh cli neovim   # only the named steps
#   FORCE=1 ./install.sh cli  # reinstall even if already present
#
# Steps are idempotent: re-running skips whatever is already at the pinned
# version. Existing dotfiles are backed up to ~/.dotfiles-backup, never deleted.
#
# Deliberately bash 3.2 compatible — on a fresh Mac this runs under Apple's
# system bash before Homebrew's bash 5 is installed. No associative arrays.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES
. "$DOTFILES/lib/common.sh"

# Order matters: packages first (it provides the compilers and, on macOS, the
# shell), link before neovim (the config has to exist before plugins sync).
case "$OS" in
  linux) ORDER="packages cli fonts blesh link neovim go node python terminal" ;;
  macos) ORDER="packages shell blesh link neovim go node python terminal" ;;
esac

# Resolve a step name to its script: OS-specific version wins, else shared.
step_file() {
  if [ -f "$DOTFILES/steps/$OS/$1.sh" ]; then
    echo "steps/$OS/$1.sh"
  elif [ -f "$DOTFILES/steps/shared/$1.sh" ]; then
    echo "steps/shared/$1.sh"
  else
    return 1
  fi
}

usage() {
  echo "usage: ./install.sh [step ...]"
  echo "steps on $OS: $ORDER"
  exit "${1:-0}"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then usage; fi

have curl || die "curl is required to bootstrap"
if [ "$OS" = linux ] && [ "$ARCH" != x86_64 ]; then
  die "the Linux steps pin x86_64 downloads; $ARCH needs different URLs in steps/linux/cli.sh"
fi

requested="$*"
[ -z "$requested" ] && requested="$ORDER"

for s in $requested; do
  case " $ORDER " in
    *" $s "*) ;;
    *)
      # Give a useful answer when the step exists, just not on this OS.
      if [ "$OS" = macos ] && { [ "$s" = cli ] || [ "$s" = fonts ]; }; then
        die "on macOS the CLI tools and fonts come from macos/Brewfile — run: ./install.sh packages"
      fi
      if [ -f "$DOTFILES/steps/linux/$s.sh" ] || [ -f "$DOTFILES/steps/macos/$s.sh" ]; then
        die "step '$s' does not apply on $OS"
      fi
      echo "unknown step: $s" >&2; usage 1 ;;
  esac
  step_file "$s" >/dev/null || die "missing script for step '$s'"
done

info "$OS/$ARCH — running: $requested"
start=$SECONDS
for s in $requested; do
  printf '\n%s──────── %s ────────%s\n' "$C_INFO" "$s" "$C_OFF"
  bash "$DOTFILES/$(step_file "$s")"
done

printf '\n'
ok "done in $((SECONDS - start))s"

cat <<EOF

Next:
  • open a new terminal (or: exec bash) to pick up the new shell config
  • set your git identity in ~/.gitconfig.local if you haven't
  • copy your SSH key to ~/.ssh/id_ed25519 (never stored in this repo), or:
      ssh-keygen -t ed25519 -C "you@example.com" && gh auth login
EOF
if [ "$OS" = macos ]; then
  cat <<'EOF'
  • launch Ghostty (installed to /Applications) — it picks up
    ~/.config/ghostty/config automatically
  • if the shell step changed your login shell, quit and reopen the terminal
EOF
else
  echo "  • if you installed Docker: log out and back in for the docker group"
fi
