local Popup = require("nui.popup")
local state = require("tide.state")
local render = require("tide.render")
local Animation = require("tide.animation")

local M = {}

M.calculate_height = function()
  local lines_height = vim.api.nvim_get_option("lines")
  local statusline_height = vim.o.laststatus == 0 and 0 or 1
  local cmdline_height = vim.o.cmdheight
  local tabline_height = vim.o.showtabline == 0 and 0 or 1
  local total_height = lines_height
  local used_height = statusline_height + cmdline_height + tabline_height
  state.current_state.height = total_height - used_height
  state.current_state.row = tabline_height == 0 and 0 or 1
end

M.update_layout = function()
  if state.current_state.popup == nil then
    return
  end
  M.calculate_height()
  state.current_state.popup:update_layout({
    position = { row = state.current_state.row, col = "100%" },
    size = {
      width = state.options.width,
      height = state.current_state.height,
    },
  })
  -- clear all text in buffer
  vim.api.nvim_buf_set_lines(state.current_state.popup.bufnr, 0, -1, false, {})

  render.render()

  M.hover_current_file()
end

M.show_popup = function()
  if state.current_state.popup == nil then
    M.calculate_height()

    state.current_state.popup = Popup({
      position = { row = state.current_state.row, col = "100%" },
      size = {
        width = 1,
        height = state.current_state.height,
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

    state.current_state.popup:mount()

    local animation = Animation:initialize(
      state.options.animation_duration,
      state.options.animation_fps,
      function(fraction)
        state.current_state.popup:update_layout({
          size = {
            width = math.floor(state.options.width * fraction),
            height = state.current_state.height,
          },
        })
      end
    )
    animation:run()
  end
end

M.close = function()
  if state.current_state.popup then
    local animation = Animation:initialize(
      state.options.animation_duration,
      state.options.animation_fps,
      function(fraction)
        state.current_state.popup:update_layout({
          position = { row = state.current_state.row, col = "100%" },
          size = {
            width = state.options.width + 1 - math.floor(state.options.width * fraction),
            height = state.current_state.height,
          },
        })
      end,
      function()
        state.current_state.popup:unmount()
        state.current_state.popup = nil
      end
    )
    animation:run()
  end
end

return M
