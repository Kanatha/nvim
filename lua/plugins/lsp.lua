return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			-- Neovim 0.11+: automatic_enable calls vim.lsp.enable() for
			-- every installed server, replacing the old manual
			-- lspconfig.<server>.setup() "framework" (deprecated, removed
			-- in nvim-lspconfig v3.0.0).
			--
			-- stylua excluded: it's a formatter, but nvim-lspconfig ships
			-- an "lsp/stylua.lua" default for its `--lsp` mode, and mason
			-- installed it (for conform.nvim, as a plain CLI formatter).
			-- Auto-enabling it too would attach a second, redundant
			-- Lua client alongside lua_ls.
			automatic_enable = { exclude = { "stylua" } },
			ensure_installed = {
				"lua_ls", -- Lua
				"intelephense", -- PHP
				"ts_ls", -- JavaScript / TypeScript
				"html", -- HTML
				"gopls", -- Go
				"basedpyright", -- Python
				"eslint", -- JS/TS lint (uses the project's eslint.config.js)
				"tailwindcss", -- Tailwind class completion
				"jsonls", -- JSON (+ SchemaStore schemas)
				"yamlls", -- YAML (+ SchemaStore: GH workflows, compose, k8s)
				"buf_ls", -- Protobuf
				"dockerls", -- Dockerfile
				"docker_compose_language_service", -- docker-compose.yml
				"helm_ls", -- Helm charts
				"bashls", -- Shell scripts
				"csharp_ls", -- C# (Roslyn-based; diagnostics include .NET analyzers)
			},
			automatic_installation = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp", "b0o/schemastore.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Apply blink.cmp's capabilities to every server (nvim-lspconfig
			-- provides the base configs on the 'lsp/' runtimepath; this
			-- merges in on top of them).
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						-- gofumpt off: the argus codebase is plain gofmt
						-- (gofumpt would rewrite ~18 files).
						gofumpt = false,
						staticcheck = true,
						usePlaceholders = false,
						completeUnimported = true,
						semanticTokens = true,
						directoryFilters = { "-**/node_modules", "-web", "-.git" },
						analyses = { unusedparams = true, unusedwrite = true, nilness = true, shadow = false },
						codelenses = { test = false, tidy = true, generate = true, upgrade_dependency = true },
						hints = {
							assignVariableTypes = false,
							compositeLiteralFields = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			})

			vim.lsp.config("basedpyright", {
				settings = {
					basedpyright = {
						analysis = {
							-- "standard" rather than basedpyright's default
							-- "recommended", which floods untyped code with warnings.
							typeCheckingMode = "standard",
							autoImportCompletions = true,
							diagnosticMode = "openFilesOnly",
						},
					},
				},
			})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})

			vim.lsp.config("yamlls", {
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
						keyOrdering = false,
					},
				},
			})

			-- Helm templates are handled by helm_ls, not yamlls
			vim.filetype.add({
				pattern = {
					-- docker_compose_language_service attaches to this ft
					-- (yamlls and yaml treesitter still apply)
					[".*/docker%-compose[^/]*%.ya?ml"] = "yaml.docker-compose",
					[".*/compose[^/]*%.ya?ml"] = "yaml.docker-compose",
					[".*/templates/.*%.ya?ml"] = function(path)
						return vim.fs.root(path, "Chart.yaml") and "helm" or nil
					end,
					[".*/templates/.*%.tpl"] = "helm",
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP keymaps",
				callback = function(args)
					local opts = { buffer = args.buf }
					local map = vim.keymap.set
					map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Goto definition" }))
					map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Goto references" }))
					map(
						"n",
						"gI",
						vim.lsp.buf.implementation,
						vim.tbl_extend("force", opts, { desc = "Goto implementation" })
					)
					map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
					map(
						"n",
						"<leader>rn",
						vim.lsp.buf.rename,
						vim.tbl_extend("force", opts, { desc = "Rename symbol" })
					)
					map(
						{ "n", "v" },
						"<leader>ca",
						vim.lsp.buf.code_action,
						vim.tbl_extend("force", opts, { desc = "Code action" })
					)
					map("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Goto type definition" }))
					map("n", "<leader>ih", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
					end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
					map("n", "<leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run code lens" }))
					map(
						"n",
						"<leader>d",
						vim.diagnostic.open_float,
						vim.tbl_extend("force", opts, { desc = "Line diagnostics" })
					)
					map(
						"n",
						"]d",
						function()
							vim.diagnostic.jump({ count = 1, float = true })
						end,
						vim.tbl_extend("force", opts, { desc = "Next diagnostic" })
					)
					map(
						"n",
						"[d",
						function()
							vim.diagnostic.jump({ count = -1, float = true })
						end,
						vim.tbl_extend("force", opts, { desc = "Previous diagnostic" })
					)
				end,
			})
		end,
	},
}
