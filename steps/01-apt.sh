#!/usr/bin/env bash
# System packages (needs sudo). Everything here is Ubuntu-provided; the newer
# standalone builds of rg/fd/bat/eza/... come from step 02 instead.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

info "apt update"
sudo apt-get update -y

info "installing base packages"
sudo apt-get install -y \
  build-essential make gcc g++ pkg-config \
  git curl wget unzip zip xz-utils ca-certificates gnupg lsb-release \
  tmux tree htop jq xclip \
  fontconfig fonts-jetbrains-mono dconf-cli \
  python3-pip python3-venv python3-dev

# GitHub CLI — not in Ubuntu's archive, needs their apt repo.
if ! have gh; then
  info "installing GitHub CLI"
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y gh
fi

if [ "${SKIP_DOCKER:-0}" != 1 ]; then
  info "installing Docker"
  sudo apt-get install -y docker.io docker-compose-v2
  sudo systemctl enable --now docker 2>/dev/null || true
  if ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    warn "log out/in (or run 'newgrp docker') to use docker without sudo"
  fi
fi

ok "system packages done"
