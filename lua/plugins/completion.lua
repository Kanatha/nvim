return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	-- VSCode-format snippets for Go (iferr, fori, ...), React, SQL, etc.;
	-- blink's snippets source picks them up automatically. Expand from the
	-- menu, then <Tab>/<S-Tab> jump between placeholders.
	dependencies = { "rafamadriz/friendly-snippets" },
	opts = {
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		signature = { enabled = true },
	},
	opts_extend = { "sources.default" },
}
