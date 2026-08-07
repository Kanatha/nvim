-- Step debugging (breakpoints, variables, call stack) via Xdebug, using the
-- same DBGp protocol PhpStorm's debugger speaks. The php container already
-- connects out to host.docker.internal:9003 on every request (see
-- docker-compose.yml); this just puts a listener there.
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"mason-org/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Debug: toggle breakpoint",
			},
			{
				"<leader>ds",
				function()
					require("dap").continue()
				end,
				desc = "Debug: start/continue",
			},
			{
				"<leader>de",
				function()
					require("dap").terminate()
				end,
				desc = "Debug: stop",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			require("mason-nvim-dap").setup({
				ensure_installed = { "php" },
				automatic_installation = true,
				handlers = {},
			})

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- matches the ./data/www/html:/var/www/html volume mount in docker-compose.yml
			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Listen for Xdebug (Docker)",
					port = 9003,
					pathMappings = {
						["/var/www/html"] = "/Users/luka/work/mdocs/data/www/html",
					},
				},
			}

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })
		end,
	},
}
