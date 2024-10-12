-- ported from https://github.com/anuvyklack/animation.nvim
--
local easing = require("tide.animation.easing")

local modf = math.modf
local floor = math.floor

local function time(start)
  local t = vim.loop.hrtime() / 1e6
  if start then
    t = t - start
  end
  return t
end

local function round(x)
  return floor(x + 0.5)
end

--------------------------------------------------------------------------------

local Animation = {}
Animation.__index = Animation

function Animation:initialize(duration, fps, callback, on_finish_callback)
  self._duration = duration
  self._period = round(1000 / fps)
  self._callback = callback
  self._easing = easing.in_out_sine
  self._on_finish_callback = on_finish_callback

  return self
end

function Animation:run()
  if self._timer then
    return
  end
  self._frame = 0
  self._total_time = 0

  local timer = vim.loop.new_timer()

  timer:start(
    0,
    self._period,
    vim.schedule_wrap(function()
      self:_tick()
    end)
  )

  self._timer = timer
end

function Animation:_tick()
  if not self._timer then
    return
  end
  self._timer:stop()

  local period, duration = self._period, self._duration
  local elapsed = (self._frame == 0) and period or round(time(self._start))
  local total_time = self._total_time + elapsed
  self._total_time = total_time

  if elapsed == 0 then
    -- print('elapsed = 0')
    self._timer:again()
    return
  end

  local frame = self._frame + 1

  if total_time >= duration then
    -- print('total > duration ', self._frame, ' elapsed ', elapsed, ' total ', total_time)
    self._callback(1)
    self:finish()
    return
  end

  local ratio = total_time / duration
  local finish = self._callback(self._easing(ratio))
  if finish then
    self:finish()
    return
  end

  local repeat_time
  if total_time > frame * period then
    local x
    frame, x = modf(total_time / period)
    repeat_time = period - x * period
  else
    repeat_time = (frame + 1) * period - total_time
  end
  repeat_time = round(repeat_time)
  repeat_time = (repeat_time ~= 0) and repeat_time or period
  self._timer:set_repeat(repeat_time)
  self._frame = frame

  -- print(string.format('%2d   elapsed %2d   repeat %2d   total %3d',
  --                     frame, elapsed, repeat_time, total_time))

  self._start = time()
  self._timer:again()
end

function Animation:finish()
  if self._timer then
    self._timer:close()
    self._timer = nil
  end
  if self._on_finish_callback ~= nil then
    self._on_finish_callback()
  end
end

return Animation
