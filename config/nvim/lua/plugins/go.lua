-- Go-specific workflow: tests, debugging, and the codegen chores
-- (struct tags, interface stubs, `if err != nil`) that gopls does not cover.

return {
	{
		"olexsmir/gopher.nvim",
		ft = "go",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{ "<leader>gsj", "<cmd>GoTagAdd json<cr>", desc = "Add json struct tags" },
			{ "<leader>gsy", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml struct tags" },
			{ "<leader>gsd", "<cmd>GoTagRm json<cr>", desc = "Remove json struct tags" },
			{ "<leader>gie", "<cmd>GoIfErr<cr>", desc = "Insert if err != nil" },
			{ "<leader>gim", "<cmd>GoImpl<cr>", desc = "Implement interface" },
			{ "<leader>gtj", "<cmd>GoMod tidy<cr>", desc = "go mod tidy" },
		},
	},

	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"fredrikaverpil/neotest-golang",
		},
		keys = {
			{
				"<leader>tt",
				function()
					require("neotest").run.run()
				end,
				desc = "Test nearest",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Test file",
			},
			{
				"<leader>ta",
				function()
					require("neotest").run.run(vim.uv.cwd())
				end,
				desc = "Test all",
			},
			{
				"<leader>td",
				function()
					require("neotest").run.run({ suite = false, strategy = "dap" })
				end,
				desc = "Debug nearest test",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Test summary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true, auto_close = true })
				end,
				desc = "Test output",
			},
			{
				"<leader>tp",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Test output panel",
			},
			{
				"<leader>tS",
				function()
					require("neotest").run.stop()
				end,
				desc = "Stop test",
			},
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-golang")({
						go_test_args = { "-v", "-race", "-count=1" },
						dap_go_enabled = true,
					}),
				},
				quickfix = { enabled = false },
				output = { open_on_run = false },
			})
		end,
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				config = function()
					local dap, dapui = require("dap"), require("dapui")
					dapui.setup()
					-- Open the debugger UI only while a session is live.
					dap.listeners.before.attach.dapui_config = dapui.open
					dap.listeners.before.launch.dapui_config = dapui.open
					dap.listeners.before.event_terminated.dapui_config = dapui.close
					dap.listeners.before.event_exited.dapui_config = dapui.close
				end,
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = { virt_text_pos = "eol" },
			},
			{
				"leoluz/nvim-dap-go",
				opts = { delve = { detached = true } },
			},
		},
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "))
				end,
				desc = "Conditional breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue / start",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
			},
			{
				"<leader>dq",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
			},
			{
				"<leader>dt",
				function()
					require("dap-go").debug_test()
				end,
				desc = "Debug test under cursor",
			},
			{
				"<leader>dl",
				function()
					require("dap-go").debug_last_test()
				end,
				desc = "Debug last test",
			},
		},
		config = function()
			local sign = vim.fn.sign_define
			sign("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
			sign("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn" })
			sign("DapStopped", { text = "", texthl = "DiagnosticInfo", linehl = "Visual" })
		end,
	},
}
