return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local map = vim.keymap.set
				local opts = { buffer = bufnr }

				map("n", "]h", gs.next_hunk, vim.tbl_extend("force", opts, { desc = "Next git hunk" }))
				map("n", "[h", gs.prev_hunk, vim.tbl_extend("force", opts, { desc = "Previous git hunk" }))
				map("n", "<leader>hs", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
				map("n", "<leader>hr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
				map("n", "<leader>hp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
				map(
					"n",
					"<leader>hb",
					function()
						gs.blame_line({ full = true })
					end,
					vim.tbl_extend("force", opts, { desc = "Blame line" })
				)
			end,
		},
	},
	{
		-- Review a branch/PR side by side, or a file's history.
		-- In the view: <Tab>/<S-Tab> next/prev file, g? help.
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
			{
				"<leader>gm",
				function()
					-- everything on this branch since it left main
					vim.cmd("DiffviewOpen origin/main...HEAD")
				end,
				desc = "Diff branch vs origin/main",
			},
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
			{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
		},
		opts = {},
	},
	{
		-- Lazygit in a floating terminal
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{
				"<C-g>",
				"<cmd>lua _LAZYGIT_TOGGLE()<cr>",
				desc = "Toggle lazygit",
			},
			-- General terminals. <C-\> toggles (from normal or terminal
			-- mode); a count picks the terminal: 2<C-\> opens a second one.
			{ [[<C-\>]], "<cmd>exe v:count1 . 'ToggleTerm'<cr>", mode = { "n", "t" }, desc = "Toggle terminal" },
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
			{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (bottom)" },
			{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (right)" },
		},
		opts = {
			open_mapping = nil,
			shell = "zsh",
			persist_mode = true,
			direction = "horizontal",
			size = function(term)
				return term.direction == "vertical" and math.floor(vim.o.columns * 0.4) or 15
			end,
			float_opts = { border = "curved" },
		},
		config = function(_, opts)
			require("toggleterm").setup(opts)
			-- <Esc><Esc> hides the terminal window; the shell keeps running and
			-- <C-\> brings it back (a single <Esc> still reaches the shell, and
			-- <C-\><C-n> still drops to normal mode). Not in lazygit, which
			-- uses <Esc> a lot.
			vim.api.nvim_create_autocmd("TermOpen", {
				callback = function(args)
					if vim.api.nvim_buf_get_name(args.buf):find("lazygit") then
						return
					end
					vim.keymap.set("t", "<Esc><Esc>", function()
						local term = require("toggleterm.terminal").get(vim.b.toggle_number)
						if term then
							term:close()
						else
							vim.cmd.stopinsert()
						end
					end, { buffer = args.buf, desc = "Hide terminal" })
				end,
			})
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				hidden = true,
				direction = "float",
				float_opts = { border = "curved" },
			})
			function _LAZYGIT_TOGGLE()
				lazygit:toggle()
			end
		end,
	},
}
