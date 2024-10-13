local state = require("tide.state")
local panel = require("tide.panel")
local render = require("tide.render")

local M = {}

M.toggle_panel = function()
  if state.current_state.popup then
    panel.close()
  else
    panel.show_popup()
    render.render()
    render.hover_current_file()
  end
end

M.tag_current_file = function()
  local current_file = vim.api.nvim_buf_get_name(0)
  if vim.tbl_contains(state.current_state.files, current_file) then
    return
  end
  table.insert(state.current_state.files, current_file)

  for i, file in ipairs(state.current_state.files) do
    local tag = state.options.hints.dictionary:sub(i, i)
    state.current_state.tags[tag] = file
  end

  if state.current_state.popup then
    render.render()
    render.hover_file(current_file)
  end

  M.attach_dynamic_mappings()
  state.save_state()
end

M.delete_tag = function(tag)
  local file = state.current_state.tags[tag]
  state.current_state.files = vim.tbl_filter(function(f)
    return f ~= file
  end, state.current_state.files)
  state.current_state.tags[tag] = nil

  if state.current_state.popup then
    render.render()
  end
  M.attach_dynamic_mappings()
  state.save_state()
end

M.open_tag = function(tag)
  vim.cmd(string.format(":edit %s", state.current_state.tags[tag]))
end

M.open_horizontal = function(tag)
  vim.cmd(string.format(":sp %s", state.current_state.tags[tag]))
end

M.open_vertical = function(tag)
  vim.cmd(string.format(":vsp %s", state.current_state.tags[tag]))
end

M.clear_all = function()
  state.current_state.tags = {}
  state.current_state.files = {}
  if state.current_state.popup then
    render.render()
  end
  M.attach_dynamic_mappings()
  state.save_state()
end

M.attach_mappings = function()
  -- set basic mapping
  vim.keymap.set(
    "n",
    state.options.keys.leader .. state.options.keys.leader,
    M.toggle_panel,
    { noremap = true, silent = true, desc = "tide panel" }
  )

  vim.keymap.set(
    "n",
    state.options.keys.leader .. state.options.keys.add_item,
    M.tag_current_file,
    { noremap = true, silent = true, desc = "add to tide" }
  )

  vim.keymap.set(
    "n",
    state.options.keys.leader .. state.options.keys.clear_all,
    M.clear_all,
    { noremap = true, silent = true, desc = "clear all tide files" }
  )
end

M.attach_dynamic_mappings = function()
  for i = 1, #state.options.hints.dictionary do
    local key = state.options.hints.dictionary:sub(i, i)

    local open_key = state.options.keys.leader .. key
    local delete_key = state.options.keys.leader .. state.options.keys.delete .. key
    local horizontal_key = state.options.keys.leader .. state.options.keys.horizontal .. key
    local vertical_key = state.options.keys.leader .. state.options.keys.vertical .. key

    pcall(vim.api.nvim_del_keymap, "n", open_key)
    pcall(vim.api.nvim_del_keymap, "n", delete_key)
    pcall(vim.api.nvim_del_keymap, "n", horizontal_key)
    pcall(vim.api.nvim_del_keymap, "n", vertical_key)

    -- if key exists in tags, add keybinding
    if state.current_state.tags[key] then
      -- set open keymap
      vim.keymap.set("n", open_key, function()
        M.open_tag(key)
      end, { noremap = true, silent = true, desc = "open " .. state.current_state.tags[key] })

      -- set delete keymap
      vim.keymap.set("n", delete_key, function()
        M.delete_tag(key)
      end, { noremap = true, silent = true, desc = "delete " .. state.current_state.tags[key] })

      -- set horizontal keymap
      vim.keymap.set("n", horizontal_key, function()
        M.open_horizontal(key)
      end, { noremap = true, silent = true, desc = "open horizontal " .. state.current_state.tags[key] })

      -- set vertical keymap
      vim.keymap.set("n", vertical_key, function()
        M.open_vertical(key)
      end, { noremap = true, silent = true, desc = "open vertical " .. state.current_state.tags[key] })
    end
  end
end

return M
