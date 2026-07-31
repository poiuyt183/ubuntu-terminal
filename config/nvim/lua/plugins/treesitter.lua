-- nvim-treesitter `main` branch: parsers are installed explicitly and
-- highlighting is started per-buffer rather than via a global enable flag.

local PARSERS = {
	"go",
	"gomod",
	"gosum",
	"gowork",
	"gotmpl",
	"lua",
	"vim",
	"vimdoc",
	"query",
	"json",
	"yaml",
	"toml",
	"proto",
	"sql",
	"dockerfile",
	"markdown",
	"markdown_inline",
	"bash",
	"diff",
	"git_rebase",
	"gitcommit",
	"regex",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()

			local installed = require("nvim-treesitter.config").get_installed("parsers")
			local missing = vim.tbl_filter(function(p)
				return not vim.tbl_contains(installed, p)
			end, PARSERS)

			if #missing > 0 then
				local handle = require("nvim-treesitter").install(missing)
				-- Interactive sessions let the compile run in the background.
				-- A headless run (the dotfiles bootstrap) would exit first, so
				-- block there until every parser is built.
				if #vim.api.nvim_list_uis() == 0 then
					pcall(function()
						handle:wait(600000)
					end)
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("go_treesitter", { clear = true }),
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
					if not lang or not vim.tbl_contains(PARSERS, lang) then
						return
					end
					pcall(vim.treesitter.start, ev.buf, lang)
					-- Treesitter indent is still opt-in on the main branch.
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			-- af/if: whole func vs body. Indispensable for Go, where you
			-- constantly yank or delete one method at a time.
			local textobjects = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["ab"] = "@block.outer",
				["ib"] = "@block.inner",
				["a/"] = "@comment.outer",
			}
			for keys, query in pairs(textobjects) do
				vim.keymap.set({ "x", "o" }, keys, function()
					select.select_textobject(query, "textobjects")
				end, { desc = "Select " .. query })
			end

			local moves = {
				["]f"] = { "@function.outer", "next_start", "Next function" },
				["]F"] = { "@function.outer", "next_end", "Next function end" },
				["[f"] = { "@function.outer", "previous_start", "Prev function" },
				["[F"] = { "@function.outer", "previous_end", "Prev function end" },
			}
			for keys, spec in pairs(moves) do
				vim.keymap.set({ "n", "x", "o" }, keys, function()
					move["goto_" .. spec[2]](spec[1], "textobjects")
				end, { desc = spec[3] })
			end
		end,
	},
}
