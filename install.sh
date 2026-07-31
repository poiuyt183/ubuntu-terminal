#!/usr/bin/env bash
#
# Reproduce this terminal setup on a fresh Ubuntu machine.
#
#   ./install.sh              # everything, in order
#   ./install.sh link         # just re-link the config files
#   ./install.sh cli neovim   # only the named steps
#   FORCE=1 ./install.sh cli  # reinstall even if already present
#
# Steps are idempotent: re-running skips whatever is already at the pinned
# version. Existing dotfiles are backed up to ~/.dotfiles-backup, never deleted.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES
. "$DOTFILES/lib/common.sh"

declare -A STEPS=(
  [apt]=01-apt.sh
  [cli]=02-cli.sh
  [neovim]=03-neovim.sh
  [go]=04-go.sh
  [node]=05-node.sh
  [python]=06-python.sh
  [blesh]=07-blesh.sh
  [fonts]=08-fonts.sh
  [terminal]=09-terminal.sh
  [link]=10-link.sh
)
ORDER=(apt cli fonts blesh link neovim go node python terminal)

usage() {
  echo "usage: ./install.sh [step ...]"
  echo "steps: ${ORDER[*]}"
  exit "${1:-0}"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then usage; fi

case "$(uname -m)" in
  x86_64) ;;
  *) die "these binaries are pinned to x86_64; $(uname -m) needs different URLs in versions.env" ;;
esac
have curl || die "curl is required to bootstrap (sudo apt install curl)"

requested=("$@")
[ ${#requested[@]} -eq 0 ] && requested=("${ORDER[@]}")

for s in "${requested[@]}"; do
  [ -n "${STEPS[$s]:-}" ] || { echo "unknown step: $s" >&2; usage 1; }
done

start=$SECONDS
for s in "${requested[@]}"; do
  printf '\n%s──────── %s ────────%s\n' "$C_INFO" "$s" "$C_OFF"
  bash "$DOTFILES/steps/${STEPS[$s]}"
done

printf '\n'
ok "done in $((SECONDS - start))s"
cat <<'EOF'

Next:
  • open a new terminal (or: exec bash) to pick up the new shell config
  • set your git identity in ~/.gitconfig.local if you haven't
  • copy your SSH key to ~/.ssh/id_ed25519 (never stored in this repo), or:
      ssh-keygen -t ed25519 -C "you@example.com" && gh auth login
  • if you installed Docker: log out and back in for the docker group
EOF
