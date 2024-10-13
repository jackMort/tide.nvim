local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local state = require("tide.state")
local utils = require("tide.utils")

local MENU_HEIGHT = 13

local M = {}

--- Renders the current state of the plugin.
--
-- @return nil
M.render = function()
  -- reset linenr
  state.current_state.linenr = 1

  M.render_empty_line()
  M.render_header("󱐋 Tide")
  M.render_separator()

  -- join files with and leader key
  local files = state.current_state.files

  if #files == 0 then
    M.render_comment("No files found...")
  end

  local unique_names = utils.generate_unique_names(files)

  for tag, file in pairs(state.current_state.tags) do
    state.current_state.tags[tag] = file
    M.render_file(utils.get_icon(file), unique_names[file], tag)
  end

  for _ = state.current_state.linenr, state.current_state.height - MENU_HEIGHT do
    M.render_empty_line()
  end

  M.render_separator()
  M.render_header("Shortcuts")
  M.render_separator()

  M.render_shortcut("", "Add to tide", state.options.keys.leader .. state.options.keys.add_item, "TideLine")
  M.render_shortcut("", "Toggle panel", state.options.keys.leader .. state.options.keys.panel, "TideLine")
  M.render_separator()
  M.render_shortcut("", "Open in window", state.options.keys.leader .. " + char", "TideLine")
  M.render_shortcut(
    "",
    "Open horizontal",
    state.options.keys.leader .. state.options.keys.horizontal .. " + char",
    "TideLine"
  )
  M.render_shortcut(
    "",
    "Open vertical",
    state.options.keys.leader .. state.options.keys.vertical .. " + char",
    "TideLine"
  )
  M.render_separator()
  M.render_shortcut(
    "",
    "Delete item",
    state.options.keys.leader .. state.options.keys.delete .. " + char",
    "TideLine"
  )
  M.render_shortcut("", "Clear all", state.options.keys.leader .. state.options.keys.clear_all, "TideError")
end

M.render_line = function(line)
  line:render(state.current_state.popup.bufnr, state.namespace_id, state.current_state.linenr)
  state.current_state.linenr = state.current_state.linenr + 1
end

M.render_separator = function()
  M.render_line(NuiLine({ NuiText(" " .. string.rep("─", state.options.width - 2), "TideSeparator") }))
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
  local full_text = string.format("  %s %s", ico or "", text)
  M.render_line(NuiLine({
    NuiText(full_text, "TideLine"),
    NuiText(string.rep(" ", state.options.width - #full_text - #tag)),
    NuiText(tag, "TideHotKey"),
    NuiText("  "),
  }))
end

M.render_shortcut = function(ico, text, tag, hl)
  local full_text = string.format("  %s %s", ico, text)
  M.render_line(NuiLine({
    NuiText(full_text, hl),
    NuiText(string.rep(" ", state.options.width - #full_text - #tag)),
    NuiText(tag, "LineNr"),
    NuiText("  "),
  }))
end

M.hover_current_file = function()
  local current_buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(current_buf)
  M.hover_file(filename)
end

M.hover_file = function(file)
  vim.api.nvim_buf_clear_namespace(state.current_state.popup.bufnr, state.namespace_hover_id, 0, -1)
  local files = state.current_state.files
  for i, f in ipairs(files) do
    if f == file then
      vim.api.nvim_buf_add_highlight(
        state.current_state.popup.bufnr,
        state.namespace_hover_id,
        "TideHover",
        i + 2,
        0,
        -1
      )
    else
    end
  end
end

return M
