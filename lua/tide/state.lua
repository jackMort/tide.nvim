local colors = require("tide.colors")

local M = {}

function M.defaults()
  local defaults = {
    width = 38,
    keys = {
      leader = ";",
      panel = ";",
      add_item = "a",
      delete = "d",
      clear_all = "x",
      horizontal = "-",
      vertical = "|",
    },
    animation_duration = 300,
    animation_fps = 30,
    hints = {
      dictionary = "qwertzuiopsfghjklycvbnm",
    },
  }
  return defaults
end

M.options = {}

--- Sets the current state of the application.
M.current_state = {
  mode = nil,
  popup = nil,
  tags = {},
  height = 0,
  row = 0,
  linenr = 1,
  files = {},
}

--- Creates a namespace for the plugin
M.namespace_id = vim.api.nvim_create_namespace("tide.nvim")
M.namespace_hover_id = vim.api.nvim_create_namespace("tide.nvim.hover")

function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults(), options)

  vim.api.nvim_set_hl(0, "TideBg", { bg = "#252434" })
  vim.api.nvim_set_hl(0, "TideHeader", { fg = "#D9E0EE", bold = true })
  vim.api.nvim_set_hl(0, "TideSeparator", { fg = "#383747" })
  vim.api.nvim_set_hl(0, "TideHotKey", { fg = "#F38BA8", bold = true })
  vim.api.nvim_set_hl(0, "TideError", { fg = "#ffa5c3" })
  vim.api.nvim_set_hl(0, "TideLine", { fg = "#D9E0EE" })
  vim.api.nvim_set_hl(0, "TideComment", { fg = "#605f6f", italic = true })
  vim.api.nvim_set_hl(0, "TideHover", { fg = colors.yellow, bg = "#383747" })
end

return M
