-- Finds Models/Controllers/Views across the Yii2 app dirs and vendor/mikrografija
-- packages, resolving vendor symlinks back to their real source in extensions/.
local M = {}

local MVC_TYPES = { models = "Model", controllers = "Controller", views = "View" }
local APP_DIRS = { "frontend", "common", "console" }

local function get_app_root()
	local cwd = vim.fn.getcwd()
	local candidates = { cwd, cwd .. "/data/www/html" }
	for _, c in ipairs(candidates) do
		if vim.fn.isdirectory(c .. "/frontend") == 1 then
			return c
		end
	end
	return cwd
end

local function find_php_files(dir)
	if vim.fn.isdirectory(dir) == 0 then
		return {}
	end
	local results = vim.fn.systemlist({ "find", dir, "-type", "f", "-name", "*.php" })
	local filtered = {}
	for _, path in ipairs(results) do
		if not path:match("/tests/") then
			table.insert(filtered, path)
		end
	end
	return filtered
end

local function relpath(root, file)
	if file:sub(1, #root) == root then
		return file:sub(#root + 2)
	end
	return file
end

function M.find_mvc()
	local ok_pickers, pickers = pcall(require, "telescope.pickers")
	if not ok_pickers then
		vim.notify("Telescope not available", vim.log.levels.ERROR)
		return
	end
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local entry_display = require("telescope.pickers.entry_display")

	local app_root = get_app_root()

	local roots = {}
	for _, dir in ipairs(APP_DIRS) do
		table.insert(roots, app_root .. "/" .. dir)
	end

	local vendor_base = app_root .. "/vendor/mikrografija"
	if vim.fn.isdirectory(vendor_base) == 1 then
		for _, name in ipairs(vim.fn.readdir(vendor_base)) do
			table.insert(roots, vendor_base .. "/" .. name)
		end
	end

	local items = {}
	local seen = {}
	for _, root in ipairs(roots) do
		for type_dir, label in pairs(MVC_TYPES) do
			local files = find_php_files(root .. "/" .. type_dir)
			for _, raw_path in ipairs(files) do
				local real_path = vim.loop.fs_realpath(raw_path) or raw_path
				if not seen[real_path] then
					seen[real_path] = true
					local linked_via = nil
					if real_path ~= raw_path then
						linked_via = relpath(app_root, raw_path)
					end
					table.insert(items, {
						path = real_path,
						type_label = label,
						rel_path = relpath(app_root, real_path),
						linked_via = linked_via,
					})
				end
			end
		end
	end

	table.sort(items, function(a, b)
		return a.rel_path < b.rel_path
	end)

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 11 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		local suffix = entry.value.linked_via and ("  (linked from " .. entry.value.linked_via .. ")") or ""
		return displayer({
			{ "[" .. entry.value.type_label .. "]", "TelescopeResultsIdentifier" },
			entry.value.rel_path .. suffix,
		})
	end

	pickers
		.new({}, {
			prompt_title = "Models / Controllers / Views",
			finder = finders.new_table({
				results = items,
				entry_maker = function(item)
					return {
						value = item,
						display = make_display,
						ordinal = item.type_label .. " " .. item.rel_path .. (item.linked_via or ""),
						filename = item.path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}),
		})
		:find()
end

return M
