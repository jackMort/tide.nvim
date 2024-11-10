# Tide.nvim

![GitHub Workflow Status](http://img.shields.io/github/actions/workflow/status/jackMort/tide.nvim/default.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

**Tide.nvim** is a Neovim plugin designed to streamline your workflow by helping you manage and quickly switch between frequently used files. It's similar to tools like [Harpoon](https://github.com/ThePrimeagen/harpoon), [Arrow](https://github.com/Andersbakken/arrow), and [Snipe](https://github.com/leepark81/snipe.nvim), allowing you to focus more on coding and less on file navigation.

The UI design of Tide.nvim is inspired by/based on [menu.nvim](https://github.com/NvChad/menu), providing a simple and intuitive file management interface. Kudos to author for the inspiration!

![Preview](https://github.com/jackMort/tide.nvim/blob/media/preview.png?raw=true)

## Features

- Quick file management and switching.
- Simple setup with optional customization.
- Integration with [nui.nvim](https://github.com/MunifTanjim/nui.nvim) for enhanced UI elements and [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) for file icons.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jackMort/tide.nvim",
  opts = {
      -- optional configuration
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons"
  }
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
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

## Default Configuration

Here are the default settings for Tide.nvim, which you can adjust in the `setup()` function:

```lua
{
  keys = {
    leader = ";",           -- Leader key to prefix all Tide commands
    panel = ";",            -- Open the panel (uses leader key as prefix)
    add_item = "a",         -- Add a new item to the list (leader + 'a')
    delete = "d",           -- Remove an item from the list (leader + 'd')
    clear_all = "x",        -- Clear all items (leader + 'x')
    horizontal = "-",       -- Split window horizontally (leader + '-')
    vertical = "|",         -- Split window vertically (leader + '|')
  },
  animation_duration = 300,  -- Animation duration in milliseconds
  animation_fps = 30,        -- Frames per second for animations
  hints = {
    dictionary = "qwertzuiopsfghjklycvbnm",  -- Key hints for quick access
  },
}
```

### Keybindings Explained

- **Leader key (`;`)**: This is the prefix for all Tide.nvim commands. When you press the leader key, it triggers Tide and allows you to run the subsequent commands.
  - `; ;` → Opens the Tide panel.
  - `; a` → Adds a new item to the list.
  - `; d` → Deletes an item from the list.
  - `; x` → Clears all items.
  - `; -` → Opens a file in a horizontal split.
  - `; |` → Opens a file in a vertical split.

## Usage

Once installed and configured, Tide.nvim enables you to manage and switch between your most-used files quickly using the keybindings mentioned above. Since there is currently no official documentation, this `README` serves as a guide to get you started. You can adjust key mappings and other configurations through the `setup()` function based on your workflow needs.
For more detailed usage examples and potential updates, check the [Tide.nvim repository](https://github.com/jackMort/tide.nvim).


[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jackMort)

