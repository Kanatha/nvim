return {
	{
		-- vim-surround style: cs'" change ' to ", ds" delete, ysiw) wrap
		-- word, yss) wrap line, S) in visual mode. (Replaced mini.surround,
		-- whose keys are sa/sd/sr.)
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},
	{
		"echasnovski/mini.pairs",
		version = "*",
		event = "InsertEnter",
		opts = {},
	},
	{
		-- Popup showing available keybindings as you type a prefix
		-- (e.g. press <leader> and wait) — helpful discoverability net
		-- for all the custom keymaps in this config.
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			-- labels for the <leader> prefixes
			spec = {
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code" },
				{ "<leader>D", group = "debug" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>h", group = "hunk" },
				{ "<leader>i", group = "inlay hints" },
				{ "<leader>q", group = "session" },
				{ "<leader>s", group = "sql / database" },
				{ "<leader>t", group = "terminal" },
				{ "<leader>u", group = "ui toggles" },
				{ "<leader>w", group = "window" },
				{ "<leader>x", group = "trouble (lists)" },
			},
		},
	},
}
