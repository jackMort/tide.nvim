local Popup = require("nui.popup")
local NuiLine = require("nui.line")
local NuiText = require("nui.text")

local Animation = require("tide.animation")
local Utils = require("tide.utils")
local colors = require("tide.colors")

local WIDTH = 38
local MENU_HEIGHT = 13

local M = {}

--- Creates a namespace for the plugin
M.namespace_id = vim.api.nvim_create_namespace("tide.nvim")
M.namespace_hover_id = vim.api.nvim_create_namespace("tide.nvim.hover")

---
-- @table config
--
M.config = {}

function M.defaults()
  local defaults = {
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

--- Sets up the highlight groups for the pommodoro clock.
--
-- @return nil
M.setup = function(config)
  config = config or {}
  M.config = vim.tbl_deep_extend("force", {}, M.defaults(), config)

  vim.api.nvim_set_hl(0, "TideBg", { bg = "#252434" })
  vim.api.nvim_set_hl(0, "TideHeader", { fg = "#D9E0EE", bold = true })
  vim.api.nvim_set_hl(0, "TideSeparator", { fg = "#383747" })
  vim.api.nvim_set_hl(0, "TideHotKey", { fg = "#F38BA8", bold = true })
  vim.api.nvim_set_hl(0, "TideError", { fg = "#ffa5c3" })
  vim.api.nvim_set_hl(0, "TideLine", { fg = "#D9E0EE" })
  vim.api.nvim_set_hl(0, "TideComment", { fg = "#605f6f", italic = true })
  vim.api.nvim_set_hl(0, "TideHover", { fg = colors.yellow, bg = "#383747" })

  M.attach_mappings()
end

--- Sets the current state of the application.
--
-- @param mode The mode of the application.
-- @param popup The popup of the application.
M.current_state = {
  mode = nil,
  popup = nil,
  tags = {},
  height = 0,
  row = 0,
  linenr = 1,
  files = {},
}

--- Starts the timer.
--
-- @param mode The mode to start the timer in.
M.panel = function()
  if M.current_state.popup then
    M.close()
  else
    M.show_popup()
    M.render()
    M.hover_current_file()
  end
end

M.hover_current_file = function()
  local current_buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(current_buf)
  M.hover_file(filename)
end

M.add_item = function()
  -- add current buffer to tide
  local current_file = vim.api.nvim_buf_get_name(0)

  -- check if file is already in tide
  if vim.tbl_contains(M.current_state.files, current_file) then
    return
  end

  table.insert(M.current_state.files, current_file)

  M.render()
  M.hover_file(current_file)

  M.attach_dynamic_mappings()
end

M.open_tag = function(tag)
  vim.cmd(string.format(":edit %s", M.current_state.tags[tag]))
end

M.open_horizontal = function(tag)
  vim.cmd(string.format(":sp %s", M.current_state.tags[tag]))
end

M.open_vertical = function(tag)
  vim.cmd(string.format(":vsp %s", M.current_state.tags[tag]))
end

M.delete_tag = function(tag)
  local file = M.current_state.tags[tag]
  M.current_state.files = vim.tbl_filter(function(f)
    return f ~= file
  end, M.current_state.files)
  if M.current_state.popup then
    M.render()
  end
  M.attach_dynamic_mappings()
end

M.clear_all = function()
  M.current_state.files = {}
  if M.current_state.popup then
    M.render()
  end
  M.attach_dynamic_mappings()
end

M.attach_mappings = function()
  -- set basic mapping
  vim.keymap.set(
    "n",
    M.config.keys.leader .. M.config.keys.leader,
    M.panel,
    { noremap = true, silent = true, desc = "tide panel" }
  )

  vim.keymap.set(
    "n",
    M.config.keys.leader .. M.config.keys.add_item,
    M.add_item,
    { noremap = true, silent = true, desc = "add to tide" }
  )

  vim.keymap.set(
    "n",
    M.config.keys.leader .. M.config.keys.clear_all,
    M.clear_all,
    { noremap = true, silent = true, desc = "clear all tide files" }
  )
end

M.attach_dynamic_mappings = function()
  for i = 1, #M.config.hints.dictionary do
    local key = M.config.hints.dictionary:sub(i, i)

    local open_key = M.config.keys.leader .. key
    local delete_key = M.config.keys.leader .. M.config.keys.delete .. key
    local horizontal_key = M.config.keys.leader .. M.config.keys.horizontal .. key
    local vertical_key = M.config.keys.leader .. M.config.keys.vertical .. key

    pcall(vim.api.nvim_del_keymap, "n", open_key)
    pcall(vim.api.nvim_del_keymap, "n", delete_key)
    pcall(vim.api.nvim_del_keymap, "n", horizontal_key)
    pcall(vim.api.nvim_del_keymap, "n", vertical_key)

    -- if key exists in tags, add keybinding
    if M.current_state.tags[key] then
      -- set open keymap
      vim.keymap.set("n", open_key, function()
        M.open_tag(key)
      end, { noremap = true, silent = true, desc = "open " .. M.current_state.tags[key] })

      -- set delete keymap
      vim.keymap.set("n", delete_key, function()
        M.delete_tag(key)
      end, { noremap = true, silent = true, desc = "delete " .. M.current_state.tags[key] })

      -- set horizontal keymap
      vim.keymap.set("n", horizontal_key, function()
        M.open_horizontal(key)
      end, { noremap = true, silent = true, desc = "open horizontal " .. M.current_state.tags[key] })

      -- set vertical keymap
      vim.keymap.set("n", vertical_key, function()
        M.open_vertical(key)
      end, { noremap = true, silent = true, desc = "open vertical " .. M.current_state.tags[key] })
    end
  end
end

--- Closes the current popup and stops the timer
--
-- @return nil
M.close = function()
  if M.current_state.popup then
    local animation = Animation:initialize(M.config.animation_duration, M.config.animation_fps, function(fraction)
      M.current_state.popup:update_layout({
        position = { row = M.current_state.row, col = "100%" },
        size = {
          width = WIDTH + 1 - math.floor(WIDTH * fraction),
          height = M.current_state.height,
        },
      })
    end, function()
      M.current_state.popup:unmount()
      M.current_state.popup = nil
    end)
    animation:run()
  end
end

M.get_icon = function(filename)
  local ext = string.match(filename, "%.(%a+)$")
  local icon, _ = require("nvim-web-devicons").get_icon_color(filename, ext)
  return icon
end

M.get_files = function()
  return M.current_state.files
end

--- Renders the current state of the plugin.
--
-- @return nil
M.render = function()
  -- reset linenr
  M.current_state.linenr = 1

  M.render_empty_line()
  M.render_header("󱐋 Tide")
  M.render_separator()

  -- join files with and leader key
  local files = M.get_files()

  if #files == 0 then
    M.render_comment("No files found...")
  end

  local unique_names = Utils.generate_unique_names(files)

  for i, file in ipairs(files) do
    local tag = M.config.hints.dictionary:sub(i, i)
    M.current_state.tags[tag] = file
    M.render_file(M.get_icon(file), unique_names[file], tag)
  end

  for _ = M.current_state.linenr, M.current_state.height - MENU_HEIGHT do
    M.render_empty_line()
  end

  M.render_separator()
  M.render_header("Shortcuts")
  M.render_separator()

  M.render_shortcut("", "Add to tide", M.config.keys.leader .. M.config.keys.add_item, "TideLine")
  M.render_shortcut("", "Toggle panel", M.config.keys.leader .. M.config.keys.panel, "TideLine")
  M.render_separator()
  M.render_shortcut("", "Open in window", M.config.keys.leader .. " + char", "TideLine")
  M.render_shortcut("", "Open horizontal", M.config.keys.leader .. M.config.keys.horizontal .. " + char", "TideLine")
  M.render_shortcut("", "Open vertical", M.config.keys.leader .. M.config.keys.vertical .. " + char", "TideLine")
  M.render_separator()
  M.render_shortcut("", "Delete item", M.config.keys.leader .. M.config.keys.delete .. " + char", "TideLine")
  M.render_shortcut("", "Clear all", M.config.keys.leader .. M.config.keys.clear_all, "TideError")
end

M.render_line = function(line)
  line:render(M.current_state.popup.bufnr, M.namespace_id, M.current_state.linenr)
  M.current_state.linenr = M.current_state.linenr + 1
end

M.render_separator = function()
  M.render_line(NuiLine({ NuiText(" " .. string.rep("─", WIDTH - 2), "TideSeparator") }))
end

M.render_header = function(text)
  M.render_line(NuiLine({ NuiText("  " .. text, "TideHeader") }))
end

M.render_empty_line = function()
  M.render_line(NuiLine({ NuiText(" ") }))
end

M.render_comment = function(text)
  M.render_line(NuiLine({ NuiText("  " .. text, "TideComment") }))
end

M.render_file = function(ico, text, tag)
  local full_text = string.format("  %s %s", ico, text)
  M.render_line(NuiLine({
    NuiText(full_text, "TideLine"),
    NuiText(string.rep(" ", WIDTH - #full_text - #tag)),
    NuiText(tag, "TideHotKey"),
    NuiText("  "),
  }))
end

M.render_shortcut = function(ico, text, tag, hl)
  local full_text = string.format("  %s %s", ico, text)
  M.render_line(NuiLine({
    NuiText(full_text, hl),
    NuiText(string.rep(" ", WIDTH - #full_text - #tag)),
    NuiText(tag, "LineNr"),
    NuiText("  "),
  }))
end

--
-- private methods
--
M.calculate_height = function()
  local lines_height = vim.api.nvim_get_option("lines")
  local statusline_height = vim.o.laststatus == 0 and 0 or 1 -- height of the statusline if present
  local cmdline_height = vim.o.cmdheight -- height of the cmdline if present
  local tabline_height = vim.o.showtabline == 0 and 0 or 1 -- height of the tabline if present
  local total_height = lines_height
  local used_height = statusline_height + cmdline_height + tabline_height
  M.current_state.height = total_height - used_height
  M.current_state.row = tabline_height == 0 and 0 or 1
end

M.update_layout = function()
  if M.current_state.popup == nil then
    return
  end
  M.calculate_height()
  M.current_state.popup:update_layout({
    position = { row = M.current_state.row, col = "100%" },
    size = {
      width = WIDTH,
      height = M.current_state.height,
    },
  })
  -- clear all text in buffer
  vim.api.nvim_buf_set_lines(M.current_state.popup.bufnr, 0, -1, false, {})

  M.render()

  M.hover_current_file()
end

M.show_popup = function()
  if M.current_state.popup == nil then
    M.calculate_height()

    M.current_state.popup = Popup({
      position = { row = M.current_state.row, col = "100%" },
      size = {
        width = 1,
        height = M.current_state.height,
      },
      focusable = false,
      relative = "editor",
      border = {},
      buf_options = {
        modifiable = true,
        readonly = false,
      },
      win_options = {
        winhighlight = "Normal:TideBg,FloatBorder:",
      },
    })

    M.current_state.popup:mount()

    local animation = Animation:initialize(M.config.animation_duration, M.config.animation_fps, function(fraction)
      M.current_state.popup:update_layout({
        size = {
          width = math.floor(WIDTH * fraction),
          height = M.current_state.height,
        },
      })
    end)
    animation:run()
  end
end

M.on_buffer_change = function()
  if M.current_state.popup then
    local current_buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(current_buf)
    M.hover_file(buf_name)
  end
end

M.hover_file = function(file)
  vim.api.nvim_buf_clear_namespace(M.current_state.popup.bufnr, M.namespace_hover_id, 0, -1)
  local files = M.get_files()
  for i, f in ipairs(files) do
    if f == file then
      vim.api.nvim_buf_add_highlight(M.current_state.popup.bufnr, M.namespace_hover_id, "TideHover", i + 2, 0, -1)
    else
    end
  end
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = M.on_buffer_change,
  desc = "Triggers when the buffer is written or text changes",
})

vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  callback = function()
    M.update_layout()
  end,
  desc = "Triggers when the buffer is written or text changes",
})

return M
