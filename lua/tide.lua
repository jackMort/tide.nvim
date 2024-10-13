local api = require("tide.api")
local state = require("tide.state")
local panel = require("tide.panel")
local render = require("tide.render")

local M = {}

M.setup = function(options)
  state.setup(options)
  api.attach_mappings()
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function()
    if state.current_state.popup then
      local current_buf = vim.api.nvim_get_current_buf()
      local buf_name = vim.api.nvim_buf_get_name(current_buf)
      render.hover_file(buf_name)
    end
  end,
  desc = "Hover on BufEnter",
})

vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  callback = function()
    panel.update_layout()
  end,
  desc = "Update layout on VimResized",
})

return M
