local M = {}

M.notify = function(message, level, opts)
  opts = opts or {}
  opts.title = opts.title or "Tide"

  if pcall(require, "notify") then
    require("notify")(message, level, opts)
  else
    vim.notify(message)
  end
end

return M
