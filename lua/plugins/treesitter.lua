-- nvim-treesitter "main" branch (the rewrite for Neovim 0.12; the old
-- "master" branch only supports up to 0.11 and crashes on 0.12 in query
-- directives, e.g. markdown code-block injections).
--
-- main only installs parsers/queries; highlighting and indent are switched
-- on per buffer by the FileType autocmd below. Building parsers needs the
-- `tree-sitter` CLI (in ~/.local/bin) and a C compiler.

-- Baseline parsers for nvim's own config/docs, plus the languages picked
-- for this setup.
local parsers = {
	"lua",
	"vim",
	"vimdoc",
	"query",
	"bash",
	"markdown",
	"markdown_inline",
	-- PHP / Yii2
	"php",
	"javascript",
	"html",
	"css",
	"json",
	-- argus: Go services, Python perception, React/TS console, protobuf,
	-- deploy (docker/compose/helm/k8s), SQL migrations
	"go",
	"gomod",
	"gosum",
	"gowork",
	"gotmpl",
	"python",
	"typescript",
	"tsx",
	"proto",
	"yaml",
	"toml",
	"dockerfile",
	"helm",
	"sql",
	"c_sharp",
	"make",
	"diff",
	"gitcommit",
	"git_rebase",
}

-- Turn on highlighting + indent for a buffer if its parser is installed.
local function attach(buf, lang)
	if not vim.treesitter.language.add(lang) then
		return false
	end
	vim.treesitter.start(buf, lang)
	vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	return true
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- main doesn't support lazy-loading
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.install(parsers) -- async, no-op for already installed ones

			local available = {}
			for _, lang in ipairs(ts.get_available()) do
				available[lang] = true
			end

			vim.api.nvim_create_autocmd("FileType", {
				desc = "Start treesitter (installing the parser on first use)",
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang or attach(args.buf, lang) or not available[lang] then
						return
					end
					-- like master's auto_install: fetch a missing parser once,
					-- then attach when it's built
					ts.install({ lang }):await(function()
						if vim.api.nvim_buf_is_valid(args.buf) then
							attach(args.buf, lang)
						end
					end)
				end,
			})
		end,
	},
	{
		-- Text objects usable with normal vim operators (d/c/y/v), e.g.
		-- `daf` deletes a function, `cif` changes inside it, `via` selects a
		-- parameter; ]f/[f and ]c/[c jump between functions/classes.
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			for keys, capture in pairs({
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
				aa = "@parameter.outer",
				ia = "@parameter.inner",
			}) do
				vim.keymap.set({ "x", "o" }, keys, function()
					select.select_textobject(capture, "textobjects")
				end, { desc = "Select " .. capture })
			end

			local move = require("nvim-treesitter-textobjects.move")
			for keys, spec in pairs({
				["]f"] = { move.goto_next_start, "@function.outer", "Next function" },
				["[f"] = { move.goto_previous_start, "@function.outer", "Previous function" },
				["]c"] = { move.goto_next_start, "@class.outer", "Next class" },
				["[c"] = { move.goto_previous_start, "@class.outer", "Previous class" },
			}) do
				vim.keymap.set({ "n", "x", "o" }, keys, function()
					spec[1](spec[2], "textobjects")
				end, { desc = spec[3] })
			end
		end,
	},
	{
		-- Context-aware comments for nvim's built-in `gc`: JSX inside .tsx
		-- gets {/* */} instead of //, and toggles back off cleanly.
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		-- Keeps the enclosing function/class signature pinned at the top
		-- of the window while scrolling through a long body.
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = { max_lines = 3, multiline_threshold = 1 },
	},
}
