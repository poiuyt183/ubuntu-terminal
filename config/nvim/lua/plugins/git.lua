-- Diff review UI, namespaced under <leader>h (git) alongside gitsigns.
-- <leader>g stays reserved for Go commands.
--
-- Division of labour: gitsigns handles hunks inside the buffer you're editing;
-- diffview answers "what changed across this whole range".

return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	keys = {
		{ "<leader>hd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
		{ "<leader>hD", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", desc = "Diff vs origin/HEAD" },
		{ "<leader>hf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
		{ "<leader>hF", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
		{ "<leader>hf", ":DiffviewFileHistory<cr>", mode = "v", desc = "History of selection" },
		{ "<leader>hc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
	},
	opts = {
		enhanced_diff_hl = true,
		view = {
			-- Side-by-side is the readable default; the 3-pane merge tool
			-- should only appear when actually resolving conflicts.
			default = { layout = "diff2_horizontal" },
			merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
		},
		file_panel = {
			listing_style = "tree",
			win_config = { position = "left", width = 34 },
		},
		keymaps = {
			view = {
				{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
				{ "n", "<leader>e", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle file panel" } },
			},
			file_panel = {
				{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_history_panel = {
				{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
		},
	},
}
