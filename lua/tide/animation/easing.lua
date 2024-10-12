-- ported from https://github.com/anuvyklack/animation.nvim
-- https://easings.net

local pi = math.pi
local sin = math.sin
local cos = math.cos
local pow = math.pow
local M = {}

function M.line(r)
  return r
end

function M.in_out_sine(r)
  return -(cos(pi * r) - 1) / 2
end

function M.out_sine(r)
  return sin((r * pi) / 2)
end

function M.out_quad(r)
  return 1 - (1 - r) * (1 - r)
end

function M.in_out_quad(r)
  if r < 0.5 then
    return 2 * r * r
  else
    return 1 - pow(-2 * r + 2, 2) / 2
  end
end

return M
