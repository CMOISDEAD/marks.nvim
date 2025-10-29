local M = {
	enabled = true,
	wrap_m = true,
	refresh_delay_ms = 10,
}

vim.opt.signcolumn = "yes"

local ns = "MarksSigns"

local function ensure_sign_defined(letter, texthl)
	texthl = texthl or "String"
	local name = "Mark_" .. letter
	if not vim.fn.sign_getdefined(name)[1] then
		vim.fn.sign_define(name, {
			text = letter,
			texthl = texthl,
			numhl = "",
		})
	end
	return name
end

local function mark_lines(marks)
	local buf = vim.api.nvim_get_current_buf()
	for _, mark in ipairs(marks) do
		local lnum = mark.pos[2]
		local letter = mark.mark:sub(2) -- "'a" → "a"
		local is_current_buf = mark.pos[1] == buf
		if is_current_buf and lnum and lnum > 0 and letter:match("%a") then
			local texthl = letter:match("%l") and "String" or "Constant"
			local sign_name = ensure_sign_defined(letter, texthl)
			vim.fn.sign_place(0, ns, sign_name, buf, { lnum = lnum })
		end
	end
end

local function update_marks()
	if not M.enabled then
		vim.fn.sign_unplace(ns)
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	local global_marks = vim.fn.getmarklist()
	local marks = vim.fn.getmarklist(buf)

	vim.fn.sign_unplace(ns)

	if #marks == 0 and #global_marks == 0 then
		return
	end

	local valid = {}

	for _, mark in ipairs(marks) do
		if mark.mark:match("^'[a-z]$") then
			table.insert(valid, mark)
		end
	end

	for _, mark in ipairs(global_marks) do
		if mark.mark:match("^'[A-Z]$") then
			table.insert(valid, mark)
		end
	end

	mark_lines(valid)
end

M.setup = function()
	update_marks()

	vim.api.nvim_create_autocmd({
		"CursorMoved",
		"InsertLeave",
		"TextChanged",
		"TextChangedI",
		"BufEnter",
	}, {
		callback = update_marks,
	})

	vim.api.nvim_create_user_command("MarksToggle", function()
		M.enabled = not M.enabled
		update_marks()
	end, {})

	vim.keymap.set("n", "dm", function()
		local key = vim.fn.getcharstr()
		vim.cmd("delmark " .. key)
		vim.defer_fn(update_marks, M.refresh_delay_ms)
	end, {
		desc = "Remove mark",
	})

	if M.wrap_m then
		vim.keymap.set("n", "m", function()
			local ok, key = pcall(vim.fn.getcharstr)
			if not ok or not key or key == "" then
				return
			end
			vim.cmd("normal! m" .. key)
			vim.defer_fn(update_marks, M.refresh_delay_ms)
		end, {
			desc = "Wrap 'm' to update marks signs immediately",
			noremap = true,
			silent = true,
		})
	end
end

return M
