return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				go = { "gofumpt" },
				lua = { "stylua" },
				json = { "jq" },
				yaml = { "yamlfmt" },
				proto = { "buf" },
			},
			-- gofumpt is a strict superset of gofmt, so this covers both.
			format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
			default_format_opts = { lsp_format = "fallback" },
		},
		init = function()
			-- Organize imports on save. conform only rewrites text; adding and
			-- removing imports is a gopls code action, so it runs separately.
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("go_organize_imports", { clear = true }),
				pattern = "*.go",
				callback = function(ev)
					local params = vim.lsp.util.make_range_params(0, "utf-8")
					params.context = { only = { "source.organizeImports" }, diagnostics = {} }

					local results = vim.lsp.buf_request_sync(ev.buf, "textDocument/codeAction", params, 1500)
					for cid, res in pairs(results or {}) do
						for _, action in pairs(res.result or {}) do
							if action.edit then
								local enc = vim.lsp.get_client_by_id(cid).offset_encoding
								vim.lsp.util.apply_workspace_edit(action.edit, enc)
							end
						end
					end
				end,
			})
		end,
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = { go = { "golangcilint" } }

			-- golangci-lint is slow enough that running it on every keystroke
			-- would thrash; save-triggered only.
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
				group = vim.api.nvim_create_augroup("go_lint", { clear = true }),
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
