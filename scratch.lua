local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")

local json_file = vim.fn.expand("~/tmp/savedTrack.json")

---@param bufnr number
---@param prompt string
---@param opts {bufname: string | nil, value: string | nil, cwd: string | nil}|nil
local function jq_into_buf(bufnr, prompt, opts)
	prompt = prompt or "."
	opts = opts or {}
	local cmd = { "jq", prompt, json_file }
	putils.job_maker(cmd, bufnr, {
		value = opts.value,
		bufname = opts.bufname,
		cwd = opts.cwd,
	})
	vim.api.nvim_buf_set_option(bufnr, "filetype", "json")
end

local function jq(opts)
	opts = opts or {}
	opts.sorting_strategy = "ascending"
	-- local finder = finders.new_oneshot_job({ "jq", ".", json_file }, opts)
	local finder = finders.new_job(function(prompt)
		if prompt == "" then
			prompt = "."
		end
		return { "jq", prompt, json_file }
	end)
	local previewer = previewers.new_buffer_previewer({
		title = "Original file",
		define_preview = function(self)
			jq_into_buf(self.state.bufnr, ".", {
				value = ".",
				bufname = json_file,
				cwd = opts.cwd,
			})
		end,
	})
	local picker = pickers.new(opts, {
		results_title = "Preview",
		prompt_title = "JQ command",
		finder = finder,
		sorter = sorters.empty(),
		previewer = previewer,
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				---@type Picker
				local picker = actions_state.get_current_picker(prompt_bufnr)
				assert(picker ~= nil)
				local final_prompt = picker:_get_prompt()
				actions.close(prompt_bufnr)

				local new_bufnr = vim.api.nvim_create_buf(false, true)
				jq_into_buf(new_bufnr, final_prompt)
				vim.cmd.buffer(new_bufnr)
				vim.api.nvim_win_set_buf(0, new_bufnr)
			end)
			return true
		end,
	})
	picker:find()
	local results_bufnr = picker.results_bufnr
	if results_bufnr ~= nil then
		vim.api.nvim_buf_set_option(results_bufnr, "filetype", "json")
	end
end

jq()
