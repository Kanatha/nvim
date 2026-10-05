-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Restore cursor to last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Restore cursor position",
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Per-language indentation (default is 4 spaces, see options.lua)
vim.api.nvim_create_autocmd("FileType", {
	desc = "Go uses tabs",
	pattern = { "go", "gomod", "gowork", "make" },
	callback = function()
		vim.opt_local.expandtab = false
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	desc = "2-space languages",
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
		"yaml",
		"helm",
		"css",
		"html",
		"proto",
	},
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})

-- Create parent directories automatically when writing a new file
vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "Auto-create parent directories on save",
	callback = function(args)
		local dir = vim.fn.fnamemodify(args.match, ":p:h")
		vim.fn.mkdir(dir, "p")
	end,
})
