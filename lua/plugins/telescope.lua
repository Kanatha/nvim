-- Dependency/build/cache dirs kept out of find_files and grep even when a
-- project doesn't .gitignore them (.gitignore'd files are skipped anyway).
-- <leader>fF / <leader>fG search everything, these included.
local excluded_dirs = {
	".git",
	"node_modules",
	".venv",
	"venv",
	"vendor",
	"__pycache__",
	".pytest_cache",
	".mypy_cache",
	".ruff_cache",
	"dist",
	".output",
	".nitro",
	".tanstack",
	".cache",
}

local exclude_globs = {}
for _, dir in ipairs(excluded_dirs) do
	vim.list_extend(exclude_globs, { "--glob", "!**/" .. dir .. "/**" })
end

-- dotfiles included (.github/, .env.example, ...), .gitignore respected
local rg_files = vim.list_extend({ "rg", "--files", "--color=never", "--hidden" }, exclude_globs)
local rg_files_all = { "rg", "--files", "--color=never", "--hidden", "--no-ignore", "--glob", "!**/.git/**" }

return {
	"nvim-telescope/telescope.nvim",
	-- master, not the old "0.1.x" release branch: 0.1.x calls
	-- nvim-treesitter APIs that its "main" branch removed (previewer crash)
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	cmd = "Telescope",
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep project (ripgrep)" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
		{ "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
		{ "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
		{
			"<leader>fF",
			function()
				require("telescope.builtin").find_files({ find_command = rg_files_all })
			end,
			desc = "Find files incl. ignored (node_modules, ...)",
		},
		{
			"<leader>fG",
			function()
				local args = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number" }
				vim.list_extend(args, { "--column", "--smart-case", "--hidden", "--no-ignore", "--glob", "!**/.git/**" })
				require("telescope.builtin").live_grep({ vimgrep_arguments = args })
			end,
			desc = "Grep incl. ignored (node_modules, ...)",
		},
		{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Symbols in file" },
		{ "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Symbols in project" },
		{ "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git-tracked files" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			pickers = {
				find_files = { find_command = rg_files },
			},
			defaults = {
				vimgrep_arguments = vim.list_extend({
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
				}, vim.deepcopy(exclude_globs)),
				layout_strategy = "horizontal",
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<esc>"] = "close",
					},
				},
			},
		})
		pcall(telescope.load_extension, "fzf")
	end,
}
