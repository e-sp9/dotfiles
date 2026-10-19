-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt.conceallevel = 0
	end,
})

-- Snacks explorer: refresh fallback.
-- The explorer relies on libuv fs_event watchers, which on macOS can miss files
-- created while Neovim is in the background. Re-scan when Neovim regains focus,
-- and poll the mtime of expanded directories while an explorer is open.
local function explorers()
	if not package.loaded["snacks"] then
		return {}
	end
	return Snacks.picker.get({ source = "explorer", tab = false })
end

local function refresh_explorers(dirs)
	local ok, err = pcall(function()
		local Tree = require("snacks.explorer.tree")
		for _, dir in ipairs(dirs) do
			Tree:refresh(dir)
		end
		require("snacks.explorer.watch").refresh()
	end)
	if not ok then
		vim.notify_once("explorer refresh failed: " .. tostring(err), vim.log.levels.WARN)
	end
end

vim.api.nvim_create_autocmd("FocusGained", {
	group = vim.api.nvim_create_augroup("explorer_refresh", { clear = true }),
	callback = function()
		local dirs = {}
		for _, picker in ipairs(explorers()) do
			dirs[#dirs + 1] = picker:cwd()
		end
		if #dirs > 0 then
			refresh_explorers(dirs)
		end
	end,
})

local uv = vim.uv or vim.loop
local mtimes = {} ---@type table<string, number>
local poll = assert(uv.new_timer())
poll:start(
	2000,
	2000,
	vim.schedule_wrap(function()
		local pickers = explorers()
		if #pickers == 0 then
			mtimes = {}
			return
		end
		local ok, Tree = pcall(require, "snacks.explorer.tree")
		if not ok then
			return
		end
		local seen = {} ---@type table<string, boolean>
		local changed = {} ---@type string[]
		for _, picker in ipairs(pickers) do
			Tree:walk(Tree:find(picker:cwd()), function(node)
				if node.dir and node.open and not seen[node.path] then
					seen[node.path] = true
					local stat = uv.fs_stat(node.path)
					local mtime = stat and (stat.mtime.sec + stat.mtime.nsec / 1e9) or -1
					if mtimes[node.path] ~= nil and mtimes[node.path] ~= mtime then
						changed[#changed + 1] = node.path
					end
					mtimes[node.path] = mtime
				end
			end)
		end
		for dir in pairs(mtimes) do
			if not seen[dir] then
				mtimes[dir] = nil
			end
		end
		if #changed > 0 then
			refresh_explorers(changed)
		end
	end)
)
