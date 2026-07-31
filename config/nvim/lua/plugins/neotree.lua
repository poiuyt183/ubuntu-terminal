-- Persistent sidebar tree. Coexists with oil.nvim (`-`): neo-tree for browsing
-- and orientation, oil for in-buffer renames and bulk edits.

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "<leader>E", "<cmd>Neotree toggle<cr>", desc = "File tree (toggle)" },
		{ "<leader>o", "<cmd>Neotree focus reveal<cr>", desc = "File tree (reveal current)" },
		{ "<leader>hg", "<cmd>Neotree float git_status<cr>", desc = "Git status tree" },
	},
	opts = {
		close_if_last_window = true,
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = true,
		filesystem = {
			-- Keep the tree in sync with whatever buffer is focused, so it
			-- always answers "where am I in this module?".
			follow_current_file = { enabled = true, leave_dirs_open = false },
			use_libuv_file_watcher = true,
			filtered_items = {
				visible = false,
				hide_dotfiles = false,
				hide_gitignored = true,
				-- Vendored deps and build output drown out real source in a
				-- Go repo; `H` toggles them back into view when needed.
				never_show = { ".git", "node_modules" },
				hide_by_name = { "vendor" },
			},
		},
		window = {
			width = 34,
			mappings = {
				["<space>"] = "none", -- don't shadow leader inside the tree
				["l"] = "open",
				["h"] = "close_node",
				["H"] = "toggle_hidden",
				["O"] = "open_with_window_picker",
			},
		},
		default_component_configs = {
			indent = { with_expanders = true },
			git_status = {
				symbols = {
					added = "",
					modified = "",
					deleted = "✖",
					renamed = "󰁕",
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
			},
		},
	},
}
