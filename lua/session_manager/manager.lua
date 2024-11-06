local Path = require("plenary.path")
local M = {}

local pwd = vim.fn.getcwd()

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local session_dir = vim.fn.stdpath("data") .. "/session-manager-data/"
local config_file_path = session_dir .. "data.json"

local function ensure_session_dir()
	if not vim.fn.isdirectory(session_dir) then
		vim.fn.mkdir(session_dir, "p")
	end
end

local function ensure_config_file()
	if vim.fn.filereadable(config_file_path) == 0 then
		vim.fn.writefile({ "{}" }, config_file_path)
	end
end

local function get_sessions_table()
	local _, sessions_table = pcall(vim.json.decode, Path:new(config_file_path):read())
	return sessions_table
end

local function get_all_sessions()
	local sessions_table = get_sessions_table()
	local sessions = {}
	for key, _ in pairs(sessions_table) do
		table.insert(sessions, key)
	end
	return sessions
end

local function get_pwd_sessions()
	local sessions_table = get_sessions_table()
	local sessions = {}
	for key, value in pairs(sessions_table) do
		if value == pwd then
			table.insert(sessions, key)
		end
	end
	return sessions
end

-- accepts a new name for a session
-- stores a new key-value pair in `data.json` where key is accepted name of session and value is pwd
-- creates a `{accepted name of session}.vim` file for the session
local function make_creation(new_session_name)
	local sessions_table = get_sessions_table()
	sessions_table[new_session_name] = pwd
	Path:new(config_file_path):write(vim.fn.json_encode(sessions_table), "w")
	local session_file_name = session_dir .. new_session_name .. ".vim"
	vim.cmd("mksession! " .. session_file_name)
	vim.notify("Session " .. new_session_name .. ".vim created successfully!")
end

-- creates a new session
function M.create_session()
	-- first, get the names of all the sessions present
	local sessions = get_all_sessions()
	-- ask for a name for the new session
	local new_session = vim.fn.input("Enter a session name: ")

	-- if the entered name is empty, exit
	if new_session == "" then
		return
	end

	-- if there are no sessions present, make this session and exit
	if next(sessions) == nil then
		make_creation(new_session)
		return
	end

	while true do
		-- check if the entered name of session already exists
		local exists = false
		for _, session in ipairs(sessions) do
			if session == new_session then
				exists = true
				break
			end
		end

		-- if the entered name of session already exists, ask for a new name for this session
		if exists then
			print("\nA session with this name already exists.")
			new_session = vim.fn.input("Enter another session name: ")
		-- otherwise, make this session and exit
		else
			make_creation(new_session)
			return
		end
	end
end

function M.load_session()
	local pwd_sessions = get_pwd_sessions()
	if next(pwd_sessions) == nil then
		vim.notify("There are no sessions to load from.")
		return
	end
	-- launch a picker
	pickers
		.new({}, {
			prompt_title = "Select a session to open",
			results_title = "Result sessions",
			finder = finders.new_table({
				results = pwd_sessions,
			}),
			sorter = conf.generic_sorter({}),

			attach_mappings = function(_, map)
				local function select_option(prompt_bufnr)
					local selection = actions_state.get_selected_entry()
					local selected_session = selection[1]
					actions.close(prompt_bufnr)

					-- source the selected session
					local session_file = session_dir .. selected_session .. ".vim"
					if vim.fn.filereadable(session_file) == 1 then
						vim.cmd("source " .. session_file)
						vim.notify("Loaded session: " .. selected_session)
					else
						vim.notify("Session does not exist or cannot be opened", "error")
					end
				end

				map("i", "<CR>", select_option)
				map("n", "<CR>", select_option)

				return true
			end,
		})
		:find()
end

function M.update_session_name()
	local sessions_table = get_sessions_table()
	pickers
		.new({}, {
			prompt_title = "Select a session to rename",
			results_title = "Result sessions",
			finder = finders.new_table({
				results = get_pwd_sessions(),
			}),
			sorter = conf.generic_sorter({}),

			attach_mappings = function(_, map)
				local function select_option(prompt_bufnr)
					local selection = actions_state.get_selected_entry()
					local old_session_name = selection[1]
					actions.close(prompt_bufnr)

					-- ask for a new name for the session
					local new_session_name = vim.fn.input("Enter a new session name: ")
					-- if the entered name is empty, exit
					if new_session_name == "" then
						return
					end

					while true do
						local exists = false
						for _, session in ipairs(get_all_sessions()) do
							if session == new_session_name then
								exists = true
							end
						end

						-- if the entered name of session already exists, ask for a new name
						if exists then
							print("\nA session with this name already exists.")
							new_session_name = vim.fn.input("Enter another session name: ")
						-- otherwise, update the session name
						else
							-- update the table variable and write it to `data.json` file
							sessions_table[new_session_name] = sessions_table[old_session_name]
							sessions_table[old_session_name] = nil
							Path:new(config_file_path):write(vim.fn.json_encode(sessions_table), "w")

							-- rename the `.vim` file from old name to new name
							local new_session_file_name = session_dir .. new_session_name .. ".vim"
							local old_session_file_name = session_dir .. old_session_name .. ".vim"
							vim.fn.rename(old_session_file_name, new_session_file_name)
							vim.notify(
								"Session name updated from "
									.. old_session_name
									.. " to "
									.. new_session_name
									.. " successfully!"
							)
							return
						end
					end
				end

				map("i", "<CR>", select_option)
				map("n", "<CR>", select_option)

				return true
			end,
		})
		:find()
end

function M.update_session_definition()
	pickers
		.new({}, {
			prompt_title = "Select a session to update",
			results_title = "Result sessions",
			finder = finders.new_table({
				results = get_pwd_sessions(),
			}),
			sorter = conf.generic_sorter({}),

			attach_mappings = function(_, map)
				local function select_option(prompt_bufnr)
					local selection = actions_state.get_selected_entry()
					local session_name = selection[1]
					actions.close(prompt_bufnr)

					local session_file_name = session_dir .. session_name .. ".vim"
					vim.cmd("mksession! " .. session_file_name)
					vim.notify("Session " .. session_name .. " updated successfully!")
				end

				map("i", "<CR>", select_option)
				map("n", "<CR>", select_option)

				return true
			end,
		})
		:find()
end

function M.delete_session()
	local pwd_sessions = get_pwd_sessions()
	local sessions_table = get_sessions_table()
	-- TODO: pick a session to delete using telescope
	pickers
		.new({}, {
			prompt_title = "Select a session to delete",
			results_title = "Result sessions",
			finder = finders.new_table({
				results = pwd_sessions,
			}),
			sorter = conf.generic_sorter({}),

			attach_mappings = function(_, map)
				local function select_option(prompt_bufnr)
					local selection = actions_state.get_selected_entry()
					local session_name = selection[1]
					actions.close(prompt_bufnr)

					local session_file_name = session_dir .. session_name .. ".vim"
					vim.fn.delete(session_file_name)

					for key, _ in pairs(sessions_table) do
						if key == session_name then
							sessions_table[key] = nil
							Path:new(config_file_path):write(vim.fn.json_encode(sessions_table), "w")
						end
					end

					vim.notify("Session " .. session_name .. " deleted successfully!")
				end

				map("i", "<CR>", select_option)
				map("n", "<CR>", select_option)

				return true
			end,
		})
		:find()
end

function M.setup()
	ensure_session_dir()
	ensure_config_file()
	vim.cmd([[
    command! SessionCreate lua require("session_manager.manager").create_session()
    command! SessionLoad lua require("session_manager.manager").load_session()
    command! SessionUpdateName lua require("session_manager.manager").update_session_name()
    command! SessionUpdateContent lua require("session_manager.manager").update_session_definition()
    command! SessionDelete lua require("session_manager.manager").delete_session()
  ]])
end

return M
