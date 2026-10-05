-- Oil: edit the filesystem like a buffer. <leader>e opens it on the current
-- file's directory and closes it again (back to the previous buffer).
return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false, -- so `nvim .` / `:e some/dir` open in oil
	keys = {
		{
			"<leader>e",
			function()
				if vim.bo.filetype == "oil" then
					require("oil").close()
				else
					require("oil").open()
				end
			end,
			desc = "Toggle oil (file explorer)",
		},
	},
	opts = {
		default_file_explorer = true,
		view_options = { show_hidden = true },
		keymaps = {
			-- keep <C-h>/<C-l> for window navigation (keymaps.lua)
			["<C-h>"] = false,
			["<C-l>"] = false,
			["q"] = "actions.close",
			["<Esc>"] = "actions.close",
			-- h: up to the parent dir, l: open file / enter dir
			["h"] = "actions.parent",
			["l"] = "actions.select",
		},
	},
}
