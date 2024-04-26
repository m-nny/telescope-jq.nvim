local popup = require("plenary.popup")

--- A helper function for creating each of the windows in a picker
---@param bufnr number|string: the buffer number to be used in the window
---@param popup_opts table: options to pass to `popup.create`
---@param nowrap boolean: is |'wrap'| disabled in the created window
local function create_window(bufnr, popup_opts, nowrap)
	local what = bufnr or ""
	local win, opts = popup.create(what, popup_opts)

	-- a.nvim_win_set_option(win, "winblend", self.window.winblend)
	vim.api.nvim_win_set_option(win, "wrap", not nowrap)
	local border_win = opts and opts.border and opts.border.win_id
	-- if border_win then
	-- 	a.nvim_win_set_option(border_win, "winblend", self.window.winblend)
	-- end
	return win, opts, border_win
end

local window_opts = {
	preview = {
		border = true,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		borderhighlight = "TelescopePreviewBorder",
		col = 30,
		enter = false,
		height = 33,
		highlight = "TelescopePreviewNormal",
		line = 6,
		minheight = 33,
		title = "Result Preview",
		titlehighlight = "TelescopePreviewTitle",
		width = 225,
	},
	prompt = {
		border = true,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		borderhighlight = "TelescopePromptBorder",
		col = 30,
		enter = true,
		height = 1,
		highlight = "TelescopePromptNormal",
		line = 70,
		minheight = 1,
		title = "Prompt",
		titlehighlight = "TelescopePromptTitle",
		width = 225,
	},
	results = {
		border = true,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		borderhighlight = "TelescopeResultsBorder",
		col = 30,
		enter = false,
		height = 27,
		highlight = "TelescopeResultsNormal",
		line = 41,
		minheight = 27,
		title = "Original File",
		titlehighlight = "TelescopeResultsTitle",
		width = 225,
	},
}
local result_id, prompt_id, preview_id = 0, 0, 0

local function show_pp()
	local wrap_result = false
	result_id = create_window("", window_opts.results, wrap_result)
	prompt_id = create_window("", window_opts.prompt, wrap_result)
	preview_id = create_window("", window_opts.preview, wrap_result)
	print(result_id, prompt_id, preview_id)
end

local function close_pp()
	if result_id ~= 0 then
		vim.api.nvim_win_close(result_id, true)
	end
	if prompt_id ~= 0 then
		vim.api.nvim_win_close(prompt_id, true)
	end
	if preview_id ~= 0 then
		vim.api.nvim_win_close(preview_id, true)
	end
end

return { show_pp = show_pp, close_pp = close_pp }
