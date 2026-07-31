-- gopls is configured through Neovim's built-in vim.lsp.config (0.11+), so no
-- nvim-lspconfig dependency is needed for a single-language setup.

return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				-- super-tab makes <Tab> accept the selected item, then jump
				-- snippet placeholders, then fall back to a literal tab (which
				-- Go needs -- gofmt indents with real tabs).
				preset = "super-tab",
				-- Kept from the default preset: <C-y> still accepts, so muscle
				-- memory from other editors keeps working.
				["<C-y>"] = { "select_and_accept", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				accept = { auto_brackets = { enabled = true } },
				documentation = { auto_show = true, auto_show_delay_ms = 150 },
				ghost_text = { enabled = true },
			},
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			signature = { enabled = true },
			fuzzy = {
				implementation = "prefer_rust_with_warning",
				-- Auto-detection picks the musl build on this machine, which
				-- cannot be dlopen'd into a glibc Neovim ("libc.so: invalid
				-- ELF header"). Pin the gnu triple explicitly.
				prebuilt_binaries = { force_system_triple = "x86_64-unknown-linux-gnu" },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "saghen/blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			vim.lsp.config("gopls", {
				capabilities = capabilities,
				-- Plugins like diffview open buffers under their own URI scheme
				-- ("diffview://..."). gopls rejects any non-file URI with a
				-- JSON-RPC parse error, so skip activation for those buffers by
				-- not calling on_dir (see :h lsp-root_dir()).
				root_dir = function(bufnr, on_dir)
					local name = vim.api.nvim_buf_get_name(bufnr)
					if name:find("^%a[%w+.-]*://") and not name:find("^file://") then
						return
					end
					on_dir(vim.fs.root(bufnr, { "go.work", "go.mod", ".git" }) or vim.fn.getcwd())
				end,
				settings = {
					gopls = {
						-- Complete symbols from packages not yet imported, then
						-- add the import automatically on accept.
						completeUnimported = true,
						usePlaceholders = true,
						staticcheck = true,
						gofumpt = true,
						semanticTokens = true,
						analyses = {
							nilness = true,
							shadow = true,
							unusedparams = true,
							unusedwrite = true,
							unusedvariable = true,
							useany = true,
						},
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						codelenses = {
							generate = true,
							gc_details = true,
							test = true,
							tidy = true,
							upgrade_dependency = true,
							vendor = true,
							run_govulncheck = true,
						},
						-- Scanning these costs seconds on large repos and
						-- surfaces results nobody wants to jump to.
						directoryFilters = { "-.git", "-node_modules", "-vendor", "-bin" },
					},
				},
			})

			vim.lsp.enable("gopls")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("go_lsp_attach", { clear = true }),
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					local function m(keys, fn, desc, mode)
						vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = desc })
					end

					m("gd", vim.lsp.buf.definition, "Goto definition")
					m("gD", vim.lsp.buf.declaration, "Goto declaration")
					m("gi", vim.lsp.buf.implementation, "Goto implementation")
					m("gt", vim.lsp.buf.type_definition, "Goto type definition")
					m("grr", vim.lsp.buf.references, "References")
					m("K", vim.lsp.buf.hover, "Hover docs")
					m("<C-s>", vim.lsp.buf.signature_help, "Signature help", "i")
					m("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					m("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
					m("<leader>cl", vim.lsp.codelens.run, "Run code lens")

					if client and client:supports_method("textDocument/inlayHint") then
						m("<leader>uh", function()
							local on = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
							vim.lsp.inlay_hint.enable(not on, { bufnr = ev.buf })
						end, "Toggle inlay hints")
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end

					-- Since 0.12 code lenses refresh themselves once enabled;
					-- the old manual refresh autocmd is deprecated.
					if client and client:supports_method("textDocument/codeLens") then
						vim.lsp.codelens.enable(true, { bufnr = ev.buf })
					end
				end,
			})
		end,
	},
}
