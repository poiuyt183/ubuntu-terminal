# dotfiles

One terminal environment, two machines: an **Ubuntu x86_64 desktop** and an
**M1 MacBook**. bash + ble.sh + starship, tmux, Neovim (Go IDE setup), and the
CLI toolchain around them. Clone and run one script.

`install.sh` detects the OS and runs the right steps. The configs themselves —
nvim, tmux, starship, git, bashrc — are shared, single-source files with a
handful of clearly-marked OS conditionals inside, so a keybinding changed once
lands on both machines.

## Install

**Ubuntu**

```bash
sudo apt update && sudo apt install -y git curl
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles && ./install.sh
```

**macOS (Apple Silicon)**

```bash
git clone <this-repo-url> ~/dotfiles    # git comes with the Xcode CLT prompt
cd ~/dotfiles && ./install.sh
```

Then open a new terminal. First run is roughly 10–20 minutes, mostly Go tools
and treesitter parsers compiling. On the Mac it also installs Homebrew, changes
your login shell to Homebrew's bash 5 (`chsh`, asks for your password), and
installs Ghostty.

## Steps

| step | Ubuntu | macOS |
| --- | --- | --- |
| `packages` | apt: build tools, git, tmux, jq, xclip, gh, Docker | Homebrew + `macos/Brewfile` (CLI tools, fonts, Ghostty) |
| `cli` | rg, fd, bat, delta, eza, zoxide, starship, fzf, tree-sitter, zig → `~/.local/bin` | — (in the Brewfile) |
| `fonts` | JetBrainsMono Nerd Font + symbols fallback + fontconfig rule | — (in the Brewfile) |
| `shell` | — (bash 5 already) | Homebrew bash 5 + `chsh` |
| `blesh` | ble.sh nightly | same |
| `link` | symlinks every config into `$HOME` | same, plus `~/.bash_profile` |
| `neovim` | pinned tarball + plugin sync | same (darwin-arm64 tarball) |
| `go` | pinned toolchain + 7 Go tools | same |
| `node` | nvm + Node LTS | same |
| `python` | uv + CPython + ruff, black, ipython, poetry, pipx, virtualenv | same |
| `terminal` | GNOME Terminal dconf profile | Ghostty config |

```bash
./install.sh link            # re-link configs only
./install.sh neovim go       # run selected steps
./install.sh --help          # lists the steps valid on this OS
FORCE=1 ./install.sh cli     # reinstall even when already at the pinned version
SKIP_DOCKER=1 ./install.sh   # Linux: skip Docker
SKIP_CHSH=1 ./install.sh     # macOS: install bash 5 but don't change login shell
SKIP_NVIM_SYNC=1 ./install.sh neovim   # skip the headless plugin build
```

Every step is idempotent — re-running skips what's already at the pinned
version. Existing files are moved to `~/.dotfiles-backup/` before a symlink
replaces them; nothing is deleted.

## Layout

```
install.sh          entry point, OS detection and dispatch (bash 3.2 safe)
versions.env        every pinned version lives here
lib/common.sh       platform detection, download / symlink / logging helpers
steps/shared/       blesh link neovim go node python  — identical on both
steps/linux/        packages cli fonts terminal
steps/macos/        packages shell terminal
macos/Brewfile      formulae + casks for the Mac
home/               → $HOME/.bashrc .profile .blerc .tmux.conf .gitconfig
config/             → ~/.config/nvim, starship.toml, git/ignore
terminal/           gnome-terminal.dconf · ghostty/config
bin/cc              zig-backed C compiler shim (Linux, only when no gcc exists)
fontconfig/         Nerd Font fallback rule (Linux)
git/                template for the untracked ~/.gitconfig.local
```

## What you get

**Shell** — bash with [ble.sh](https://github.com/akinomyoga/ble.sh) for
fish-style grey inline suggestions (Right arrow accepts, `C-f` accepts one
word, Up/Down search history by prefix), starship two-line prompt, `z` for
smart cd, `C-r` fuzzy history / `C-t` file picker / `M-c` cd via fzf, `ls`→eza,
`cat`→bat, git diffs through delta.

**tmux** — prefix is `C-a`, mouse on, `|`/`-` split, `M-h/j/k/l` between panes
with no prefix, `M-1..5` for windows, vi copy mode piping to the system
clipboard, Catppuccin status bar on top.

**Neovim** — leader is space. lazy.nvim manages ~30 plugins pinned in
`lazy-lock.json`: gopls via the built-in LSP client with inlay hints and code
lenses, blink.cmp completion, treesitter (`main` branch) + textobjects,
conform (gofumpt on save, imports organised via a gopls code action),
nvim-lint (golangci-lint), neotest + nvim-dap for Go tests and debugging,
fzf-lua pickers, gitsigns + diffview, neo-tree and oil, which-key, trouble.

**Terminal** — Catppuccin Mocha palette and JetBrains Mono on both: GNOME
Terminal via dconf on Ubuntu, Ghostty via `terminal/ghostty/config` on the Mac.

## Notes

### Both

- **No secrets are stored here.** SSH keys, tokens and shell history stay out
  of the repo. `.bashrc` loads `~/.bashrc.local` if it exists — that's the
  place for per-machine environment variables.
- **`git config --global`** writes by replacing the file, which would break the
  `~/.gitconfig` symlink. Edit `home/gitconfig` in this repo instead, or put
  machine-local settings in `~/.gitconfig.local`.
- `git/gitconfig.local.example` carries the author's name and email as
  defaults; change them there if this repo becomes someone else's or goes
  public.
- **Go is pinned to 1.22.5** to match the machine this was exported from. It's
  an old release; bump `GO_VERSION` in `versions.env` if you want a supported
  one. Go's toolchain auto-download means modules requiring a newer compiler
  still build either way.
- **Updating a pin:** edit `versions.env`, then re-run that step, e.g.
  `./install.sh cli`. For Neovim plugins, run `:Lazy update` and commit the
  changed `config/nvim/lazy-lock.json`.

### Ubuntu

- **x86_64 only.** The `steps/linux/cli.sh` download URLs are pinned to
  `x86_64`; `install.sh` refuses to run the Linux path on another
  architecture.
- The `bin/cc` zig shim is only linked when the machine has no system C
  compiler — `~/.local/bin` comes first on `PATH` and would otherwise shadow
  `/usr/bin/cc`.

### macOS

- **Apple's bash is 3.2** (2007, kept for licensing reasons) and ble.sh needs
  4+. The `shell` step installs Homebrew's bash 5 and `chsh`es to it, which is
  what lets both machines share one `.bashrc`. `install.sh` itself stays bash
  3.2 compatible so the first run works before that happens.
- **Option must send Esc.** `macos-option-as-alt = true` in the Ghostty config
  is load-bearing: without it every `M-h/j/k/l` pane binding and `M-1..5`
  window binding in tmux silently does nothing.
- **Not installed:** Docker (add Docker Desktop or `brew install colima docker`
  by hand) and zig (only needed on the Linux box, which has no system C
  compiler — macOS has clang).
- Homebrew provides the CLI tools rather than pinned tarballs, so their
  versions track brew. Neovim and Go are still pinned tarballs on both
  machines, because the plugin lockfile and build reproducibility depend on
  them.
- **Untested on real hardware.** The macOS path was written against verified
  formula/cask names and release URLs, and every shared step was re-tested on
  Linux, but nothing has run on an actual M1 yet. Expect to fix a rough edge or
  two on first run.
