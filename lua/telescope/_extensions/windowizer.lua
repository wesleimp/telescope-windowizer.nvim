local Path = require("plenary.path")
local telescope = require("telescope")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local find_cmd = ""

local M = {}
M.windowizer = function(opts)
  local find_commands = {
    find = { "find", ".", "-type", "f" },
    fd = { "fd", "--type", "f" },
    rg = { "rg", "--files" },
  }

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

  pickers.new(opts, {
    prompt_title = "Windowizer",
    finder = finders.new_oneshot_job(find_commands[find_cmd], opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return telescope.register_extension({
  setup = function(opts)
    find_cmd = opts.find_cmd or "fd"
  end,
  exports = {
    windowizer = M.windowizer,
  },
})
