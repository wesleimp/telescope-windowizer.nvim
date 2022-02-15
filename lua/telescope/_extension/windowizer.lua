local tutils = require("telescope.utils")

local M = {}

local function has_session(window_name)
  local display_out = tutils.get_os_command_output({
    "tmux",
    "display-message",
    "-p",
    "'#S'",
  })

  local session_name
  if display_out[1] then
    session_name = display_out[1]:gsub("'", "")
  end

  local _, code = tutils.get_os_command_output({
    "tmux",
    "has-session",
    "-t",
    string.format("%s:%s", session_name, window_name),
  })
  if code ~= 0 then
    return false
  end

  return true
end

M.new_window = function(opts)
  opts = opts or {}

  local name = opts.name or nil
  local deamon = opts.deamon or true

  if not name then
    return
  end

  if has_session(name) then
    return
  end

  -- base command
  local command = { "tmux", "new-window", "-n", name }

  if deamon then
    table.insert(command, "-d")
  end

  tutils.get_os_command_output(command)
end

return M
