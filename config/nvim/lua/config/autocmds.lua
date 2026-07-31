local function augroup(name)
	return vim.api.nvim_create_augroup("go_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

-- go.mod / go.sum / go.work are not Go source but benefit from the same
-- filetype-aware handling.
vim.filetype.add({
	extension = { gotmpl = "gotmpl", tmpl = "gotmpl" },
	filename = {
		["go.work"] = "gowork",
		[".golangci.yml"] = "yaml",
		[".golangci.yaml"] = "yaml",
	},
})

-- Go's own style is tabs, but YAML/JSON around a Go repo (CI, k8s manifests)
-- must be spaces or the file is invalid.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("indent"),
	pattern = { "yaml", "json", "jsonc", "lua", "proto", "markdown" },
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("quickclose"),
	pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "dap-float" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
	end,
})
