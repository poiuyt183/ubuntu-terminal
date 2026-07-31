return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = { style = "night" },
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		keys = {
			{ "<leader><space>", "<cmd>FzfLua files<cr>", desc = "Find files" },
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>FzfLua live_grep_native<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
			{ "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
			{ "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
			{ "<leader>fd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
			-- Symbol pickers are the fastest way to move around a Go package.
			{ "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
			{ "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
		},
		opts = { "fzf-native", winopts = { preview = { default = "bat" } } },
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
			},
			on_attach = function(buf)
				local gs = require("gitsigns")
				local function m(mode, keys, fn, desc)
					vim.keymap.set(mode, keys, fn, { buffer = buf, desc = desc })
				end

				m("n", "]h", function()
					gs.nav_hunk("next")
				end, "Next hunk")
				m("n", "[h", function()
					gs.nav_hunk("prev")
				end, "Prev hunk")

				m("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				m("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
				-- Visual-mode variants stage/reset only the selected lines.
				m("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage selected lines")
				m("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset selected lines")

				m("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				m("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
				m("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Blame line (full)")
				m("n", "<leader>hB", gs.blame, "Blame file")
				m("n", "<leader>hw", gs.toggle_word_diff, "Toggle word diff")
				m("n", "<leader>hx", gs.toggle_deleted, "Toggle deleted lines")
				m("n", "<leader>hl", gs.toggle_current_line_blame, "Toggle inline blame")
				m("n", "<leader>hq", function()
					gs.setqflist("all")
				end, "All repo hunks to quickfix")

				-- ih works as a text object: `dih` discards a hunk, `vih` selects it.
				m({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
			end,
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			spec = {
				{ "<leader>g", group = "go" },
				{ "<leader>gs", group = "struct tags" },
				{ "<leader>t", group = "test" },
				{ "<leader>d", group = "debug" },
				{ "<leader>f", group = "find" },
				{ "<leader>h", group = "git" },
				{ "<leader>c", group = "code" },
				{ "<leader>b", group = "buffer" },
				{ "<leader>u", group = "ui toggle" },
			},
		},
	},

	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } },
		opts = { view_options = { show_hidden = true } },
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = { theme = "tokyonight", globalstatus = true, section_separators = "", component_separators = "|" },
			sections = {
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "diagnostics", "filetype" },
			},
		},
	},

	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{ "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
	{ "folke/todo-comments.nvim", event = "BufReadPost", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
	{
		"numToStr/Comment.nvim",
		keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
		opts = {},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
		},
		opts = {},
	},
}
