local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Move selected lines, keeping indentation correct
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Paste over a selection without clobbering the unnamed register
map("x", "p", [["_dP]])

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Terminal
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

--------------------------------------------------------------------------------
-- Go: build / test / run, routed through the quickfix list
--------------------------------------------------------------------------------

local function go_cmd(cmd, title)
	return function()
		vim.cmd("cclose")
		vim.notify(title .. "…", vim.log.levels.INFO)
		vim.system(vim.split(cmd, " "), { text = true, cwd = vim.fn.getcwd() }, function(res)
			vim.schedule(function()
				local output = (res.stdout or "") .. (res.stderr or "")
				local lines = vim.split(vim.trim(output), "\n", { trimempty = true })
				if res.code == 0 then
					vim.notify(title .. " ok", vim.log.levels.INFO)
					vim.fn.setqflist({}, "r")
					return
				end
				vim.fn.setqflist({}, "r", { title = title, lines = lines })
				vim.cmd("copen")
				vim.notify(title .. " failed", vim.log.levels.ERROR)
			end)
		end)
	end
end

map("n", "<leader>gb", go_cmd("go build ./...", "go build"), { desc = "Go build" })
map("n", "<leader>gv", go_cmd("go vet ./...", "go vet"), { desc = "Go vet" })
map("n", "<leader>gm", go_cmd("go mod tidy", "go mod tidy"), { desc = "Go mod tidy" })
map("n", "<leader>gl", go_cmd("golangci-lint run", "golangci-lint"), { desc = "golangci-lint" })
map("n", "<leader>gr", "<cmd>split | terminal go run .<cr>", { desc = "Go run ." })
