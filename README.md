# tide.nvim

![GitHub Workflow Status](http://img.shields.io/github/actions/workflow/status/jackMort/tide.nvim/default.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
Tide.nvim

Tide.nvim is a plugin similar to Harpoon, Arrow, Snipe etc. that helps developers streamline their workflow by managing and quickly switching between frequently used files.
It's designed for Neovim users who want to stay efficient and organized.

![preview image](https://github.com/jackMort/tide.nvim/blob/media/preview.gif?raw=true)

## Installation

```lua
-- lazy
{
  "jackMort/tide.nvim",
    config = function()
      require("tide").setup({
        -- optional configuration
      })
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons"
    }
}
```

```lua
-- packer
{
  "jackMort/tide.nvim",
    config = function()
      require("tide").setup({
        -- optional configuration
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons"
    }
}
```
