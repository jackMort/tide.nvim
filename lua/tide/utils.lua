local M = {}

M.get_icon = function(filename)
  local ext = string.match(filename, "%.(%a+)$")
  local icon, _ = require("nvim-web-devicons").get_icon_color(filename, ext)
  return icon
end

-- Utility function to generate unique names based on file paths
M.generate_unique_names = function(file_paths)
  local name_map = {}
  local result = {}

  -- Step 1: Extract filenames and populate the map
  for _, path in ipairs(file_paths) do
    local filename = vim.fn.fnamemodify(path, ":t") -- Get the filename (tail part)
    if not name_map[filename] then
      name_map[filename] = { count = 1, paths = { path } }
    else
      name_map[filename].count = name_map[filename].count + 1
      table.insert(name_map[filename].paths, path)
    end
  end

  -- Step 2: Ensure uniqueness by adding parent directories to both files if necessary
  for filename, data in pairs(name_map) do
    if data.count == 1 then
      -- If filename is unique, simply add it to the result
      result[data.paths[1]] = filename
    else
      -- If filename is not unique, add parent directories to all the conflicting paths
      local unique_names = {}
      for _, path in ipairs(data.paths) do
        local unique_name = filename
        local parent = vim.fn.fnamemodify(path, ":h:t") -- Get the parent directory (tail part)
        while unique_names[unique_name] or result[unique_name] do
          -- If name is still not unique, add more parent directories
          unique_name = parent .. "/" .. unique_name
          parent = vim.fn.fnamemodify(vim.fn.fnamemodify(path, ":h"), ":h:t") -- Go up one more level
        end
        unique_names[unique_name] = true -- Mark this name as used
        result[path] = unique_name -- Assign the unique name to the path
      end
    end
  end

  return result
end

return M
