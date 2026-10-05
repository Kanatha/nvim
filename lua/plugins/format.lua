return {
	{
		-- Installs the standalone formatter/linter binaries that
		-- mason-lspconfig doesn't manage (it only handles LSP servers).
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua", -- Lua formatter
				"php-cs-fixer", -- PHP formatter
				"prettier", -- JS/HTML formatter
				"selene", -- Lua linter
				"goimports", -- Go formatter (gofmt + import grouping)
				"golangci-lint", -- Go linter (same as `make lint` / CI)
				"delve", -- Go debugger
				"debugpy", -- Python debugger
				"csharpier", -- C# formatter
			},
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = { "n", "v" },
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				php = { "php_cs_fixer" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				-- conform prefers the project's own node_modules/.bin/prettier
				-- and picks up its .prettierrc (argus/web has one)
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				css = { "prettier" },
				go = { "goimports" },
				proto = { "buf" },
				-- conform runs `dotnet csharpier` when the project has it in
				-- dotnet-tools.json, else the mason-installed binary
				cs = { "csharpier" },
				-- Python intentionally has no formatter: argus/perception
				-- isn't black/ruff formatted, so format-on-save would rewrite
				-- whole files. Use <leader>cf with an LSP if you want it.
			},
			format_on_save = function(bufnr)
				if vim.bo[bufnr].filetype == "python" then
					return
				end
				return { timeout_ms = 1500, lsp_fallback = true }
			end,
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufWritePost", "BufReadPost", "InsertLeave" },
		config = function()
			local lint = require("lint")
			-- Only Lua for now: it's a standalone linter that needs no
			-- project config. eslint/phpstan need a project-level config
			-- file to be useful, so they're left out until you have one
			-- (easy to add later: lint.linters_by_ft.javascript = { "eslint_d" }).
			lint.linters_by_ft = {
				lua = { "selene" },
				go = { "golangcilint" }, -- whole-package lint, only run on save (below)
				proto = { "buf_lint" },
			}
			local on_save_only = { go = true, proto = true }
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				callback = function(args)
					if args.event == "InsertLeave" and on_save_only[vim.bo.filetype] then
						return
					end
					lint.try_lint()
				end,
			})
		end,
	},
}
