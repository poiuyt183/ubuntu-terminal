# dotfiles

Terminal environment for Ubuntu: bash + ble.sh + starship, tmux, Neovim (Go
IDE setup), and the CLI toolchain around them. Clone it onto a fresh machine
and run one script.

## Install

```bash
sudo apt update && sudo apt install -y git curl
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Then open a new terminal. First run takes roughly 10–20 minutes, mostly Go
tools and treesitter parsers compiling.

Individual steps, in the order `install.sh` runs them:

| step | what it does |
| --- | --- |
| `apt` | build tools, git, tmux, jq, xclip, fonts-jetbrains-mono, gh, Docker (needs sudo) |
| `cli` | rg, fd, bat, delta, eza, zoxide, starship, fzf, tree-sitter, zig → `~/.local/bin` |
| `fonts` | JetBrainsMono Nerd Font + Symbols Nerd Font fallback |
| `blesh` | ble.sh (inline autosuggestions in bash) |
| `link` | symlinks every config from this repo into `$HOME` |
| `neovim` | Neovim tarball + plugin sync at the pinned commits |
| `go` | Go toolchain + gopls, gofumpt, dlv, golangci-lint, gomodifytags, impl, iferr |
| `node` | nvm + Node LTS |
| `python` | uv + CPython + ruff, black, ipython, poetry, pipx, virtualenv |
| `terminal` | GNOME Terminal profile (Catppuccin Mocha, JetBrains Mono 12) |

```bash
./install.sh link            # re-link configs only
./install.sh cli neovim      # run selected steps
FORCE=1 ./install.sh cli     # reinstall even when already at the pinned version
SKIP_DOCKER=1 ./install.sh   # skip the Docker install
SKIP_NVIM_SYNC=1 ./install.sh neovim   # skip the headless plugin build
```

Every step is idempotent — re-running skips what's already at the pinned
version. Existing files are moved to `~/.dotfiles-backup/` before a symlink
replaces them; nothing is deleted.

## Layout

```
install.sh          entry point
versions.env        every pinned version lives here
lib/common.sh       download / symlink / logging helpers
steps/              one script per install step
home/               → $HOME/.bashrc .profile .blerc .tmux.conf .gitconfig
config/             → ~/.config/nvim, starship.toml, git/ignore
bin/cc              zig-backed C compiler shim (only linked when no gcc exists)
fontconfig/         Nerd Font fallback rule
terminal/           GNOME Terminal dconf profile
git/                template for the untracked ~/.gitconfig.local
```

## What you get

**Shell** — bash with [ble.sh](https://github.com/akinomyoga/ble.sh) for
fish-style grey inline suggestions (Right arrow accepts, `C-f` accepts one
word, Up/Down search history by prefix), starship two-line prompt, `z` for
smart cd, `C-r` fuzzy history / `C-t` file picker / `M-c` cd via fzf, `ls`→eza,
`cat`→bat, git diffs through delta.

**tmux** — prefix is `C-a`, mouse on, `|`/`-` split, `M-h/j/k/l` between panes
with no prefix, `M-1..5` for windows, vi copy mode piping to the X clipboard,
Catppuccin status bar on top.

**Neovim** — leader is space. lazy.nvim manages ~30 plugins pinned in
`lazy-lock.json`: gopls via the built-in LSP client with inlay hints and code
lenses, blink.cmp completion, treesitter (`main` branch) + textobjects,
conform (gofumpt on save, imports organised via a gopls code action),
nvim-lint (golangci-lint), neotest + nvim-dap for Go tests and debugging,
fzf-lua pickers, gitsigns + diffview, neo-tree and oil, which-key, trouble.

**Terminal** — Catppuccin Mocha palette, JetBrains Mono 12, Nerd Font symbol
fallback so icons render.

## Notes

- **x86_64 only.** Every download URL in `steps/` is pinned to
  `x86_64-unknown-linux-gnu`/`musl`; `install.sh` refuses to run on other
  architectures. On arm64, adjust the URLs and the
  `force_system_triple` in `config/nvim/lua/plugins/lsp.lua`.
- **Go is pinned to 1.22.5** to match the machine this was exported from. It's
  an old release; bump `GO_VERSION` in `versions.env` if you want a supported
  one. Go's toolchain auto-download means modules requiring a newer compiler
  still build either way.
- **`git config --global`** writes by replacing the file, which would break the
  `~/.gitconfig` symlink. Edit `home/gitconfig` in this repo instead, or put
  machine-local settings in `~/.gitconfig.local`.
- **No secrets are stored here.** SSH keys, tokens and shell history stay out
  of the repo. `.bashrc` loads `~/.bashrc.local` if it exists — that's the
  place for per-machine environment variables.
- `git/gitconfig.local.example` carries the author's name and email as
  defaults; change them there if this repo becomes someone else's or goes
  public.
- **Updating a pin:** edit `versions.env`, then re-run that step, e.g.
  `./install.sh cli`. For Neovim plugins, run `:Lazy update` and commit the
  changed `config/nvim/lazy-lock.json`.
