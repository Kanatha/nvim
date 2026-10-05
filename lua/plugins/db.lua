-- Database client (DBeaver-ish): vim-dadbod runs queries through the
-- database's own CLI (psql, clickhouse-client, mysql, ...), dadbod-ui adds
-- the connection/table browser, dadbod-completion feeds blink.cmp.
--
-- Keys: <leader>su toggle UI, <leader>sf find buffer, <leader>sa add
-- connection.
--
-- Connections: per project via vim.g.dbs in the project's .nvim.lua, or
-- added interactively in the UI (`A`), which saves them to
-- stdpath("data")/db_ui/connections.json.
--
-- In the UI: <CR> open/expand, `A` add connection, `R` refresh,
-- `d` delete, `H` toggle details. In a query buffer: <leader>S (normal or
-- visual) runs the buffer / selection, `<leader>W` saves the query.
return {
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		keys = {
			{ "<leader>su", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
			{ "<leader>sf", "<cmd>DBUIFindBuffer<cr>", desc = "Find buffer in DB UI" },
			{ "<leader>sa", "<cmd>DBUIAddConnection<cr>", desc = "Add DB connection" },
		},
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
			vim.g.db_ui_win_position = "left"
			vim.g.db_ui_winwidth = 36
			-- run nothing on save; do run table helpers (e.g. "List") when opened
			vim.g.db_ui_execute_on_save = 0
			vim.g.db_ui_auto_execute_table_helpers = 1
			vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
		end,
	},
	{
		-- SQL completion (tables/columns of the buffer's connection)
		"saghen/blink.cmp",
		opts = {
			sources = {
				per_filetype = {
					sql = { "dadbod", "buffer" },
					mysql = { "dadbod", "buffer" },
					plsql = { "dadbod", "buffer" },
				},
				providers = {
					dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				},
			},
		},
	},
}
