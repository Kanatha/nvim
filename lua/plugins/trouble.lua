-- A proper list for diagnostics, references, symbols and quickfix.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
		{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols outline" },
		{ "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP refs/defs/impls" },
		{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
	},
}
