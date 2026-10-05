return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
	keys = {
		-- <leader>e is oil (oil.lua); the tree lives on <leader>E
		{ "<leader>E", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Toggle file tree (at current file)" },
	},
	opts = {
		disable_netrw = true,
		-- directories open in oil instead
		hijack_directories = { enable = false },
		hijack_cursor = true,
		update_focused_file = { enable = true },
		view = { width = 32 },
		renderer = { group_empty = true },
		filters = { dotfiles = false, git_ignored = false },
		git = { enable = true },
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")

			api.config.mappings.default_on_attach(bufnr)

			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
		end,
	},
}
