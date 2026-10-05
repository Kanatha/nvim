-- Debugging: Go via delve, Python via debugpy (both installed by
-- mason-tool-installer, see format.lua). Project-specific launch targets
-- live in the project's .nvim.lua (or .vscode/launch.json, which nvim-dap
-- also reads).
--
-- Keys: F5 continue/start, F10 step over, F11 step into, F12 step out,
-- <leader>D… for everything else (<leader>d is line diagnostics).
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
			"theHamsta/nvim-dap-virtual-text",
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
		},
		keys = {
			{ "<F5>", function() require("dap").continue() end, desc = "Debug: continue / start" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
			{ "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
			{ "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{
				"<leader>DB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "))
				end,
				desc = "Conditional breakpoint",
			},
			{
				"<leader>Dp",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
				end,
				desc = "Logpoint",
			},
			{ "<leader>Dc", function() require("dap").continue() end, desc = "Continue / start" },
			{ "<leader>DC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
			{ "<leader>Dr", function() require("dap").restart() end, desc = "Restart" },
			{ "<leader>Dl", function() require("dap").run_last() end, desc = "Run last" },
			{ "<leader>Dq", function() require("dap").terminate() end, desc = "Terminate" },
			{ "<leader>Du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
			{ "<leader>De", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Eval expression" },
			{ "<leader>DR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dapui.setup()
			require("nvim-dap-virtual-text").setup({})

			-- Open/close the UI with the session
			dap.listeners.after.event_initialized.dapui = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui = function()
				dapui.close()
			end

			-- Go: delve from mason. Adds "Debug", "Attach" etc. configs.
			require("dap-go").setup({
				delve = { path = vim.fn.stdpath("data") .. "/mason/bin/dlv" },
			})

			-- Python: debugpy from mason's own venv. The *debuggee* runs with
			-- the project's interpreter (nvim-dap-python looks for
			-- $VIRTUAL_ENV, then ./venv, ./.venv), and the project's
			-- .nvim.lua can override it.
			require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "CursorLine" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
		end,
	},
}
