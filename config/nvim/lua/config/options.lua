local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Go uses real tabs; gofmt output is tab-indented and rendering them as 4
-- columns matches what everyone else sees on GitHub.
opt.expandtab = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 400

opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.winborder = "rounded"

opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.confirm = true

-- gopls emits long diagnostics; virtual_lines keeps them readable without
-- pushing code off the right edge.
vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 2 },
	severity_sort = true,
	underline = true,
	update_in_insert = false,
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
})
