local ok, telescope = pcall(require, "telescope")
if not ok then
  error(
    "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
  )
  return
end

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local make_entry = require("telescope.make_entry")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local Path = require("plenary.path")

local find_commands = {
  find = { "find", ".", "-type", "f" },
  fd = { "fd", "--type", "f" },
  rg = { "rg", "--files" },
}

local defaults = {
  find_cmd = "fd",
}

local _options = {}

local M = {}
M.windowizer = function(opts)
  opts = vim.tbl_deep_extend("force", defaults, _options, opts)

  local find_cmd = opts.find_cmd
  if not find_commands[find_cmd] then
    error(find_cmd .. " is not supported!")
    return
  end

  if not vim.fn.executable(find_cmd) then
    error(
      "You don't have " .. find_cmd .. "! Install it first or use other finder."
    )
    return
  end

  -- hidden files flag
  local hidden = _options.hidden
  local command = find_commands[find_cmd]
  if find_cmd == "fd" or find_cmd == "rg" then
    if hidden then
      table.insert(command, "--hidden")
    end
  elseif find_cmd == "find" then
    if not hidden then
      table.insert(command, { "-not", "-path", "*/.*" })
      command = vim.tbl_flatten(command)
    end
  end

  opts = opts or {}
  opts.attach_mappings = function(prompt_bufnr)
    actions.select_default:replace(function()
      local entry = action_state.get_selected_entry()[1]
      actions.close(prompt_bufnr)
      if entry then
        local path = Path:new(entry):absolute()
        local filename = entry:match("^.+/(.+)$")

        vim.api.nvim_command(
          string.format("silent !tmux neww -n %s 'nvim %s'", filename, path)
        )
      end
    end)
    return true
  end

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)
  pickers.new(opts, {
    prompt_title = "Windowizer",
    finder = finders.new_oneshot_job(command, opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return telescope.register_extension({
  setup = function(opts)
    _options = opts or {}
  end,
  exports = {
    windowizer = M.windowizer,
  },
})
