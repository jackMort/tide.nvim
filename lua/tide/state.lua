local colors = require("tide.colors")
local utils = require("tide.utils")

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
  root = "",
  state_filename = "",
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

  -- TODO: try to refactor to DRY
  M.current_state.root = utils.find_project_root()
  M.current_state.state_filename = utils.make_safe_filename(M.current_state.root) or "main"
  M.current_state.files = M.load_state() or {}
  for i, file in ipairs(M.current_state.files) do
    local tag = M.options.hints.dictionary:sub(i, i)
    M.current_state.tags[tag] = file
  end
end

local json = vim.fn.json_encode
local decode_json = vim.fn.json_decode

-- Load state from the standard Neovim data path
M.load_state = function()
  local data_path = vim.fn.stdpath("data") .. "/tide"
  local tide_file = data_path .. "/" .. M.current_state.state_filename .. ".json"

  if vim.fn.filereadable(tide_file) == 1 then
    local content = vim.fn.readfile(tide_file)
    if content and #content > 0 then
      return decode_json(table.concat(content, "\n"))
    end
  end

  return nil
end

M.save_state = function()
  local data_path = vim.fn.stdpath("data") .. "/tide"

  if vim.fn.isdirectory(data_path) == 0 then
    vim.fn.mkdir(data_path, "p")
  end

  local tide_file = data_path .. "/" .. M.current_state.state_filename .. ".json"

  local content = json(M.current_state.files or {})
  vim.fn.writefile({ content }, tide_file)
end

return M
