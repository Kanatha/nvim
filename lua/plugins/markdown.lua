-- Renders headings, tables, code blocks and checkboxes inside markdown
-- buffers (raw text shows on the cursor line). <leader>um toggles.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" },
	},
	opts = {},
}
