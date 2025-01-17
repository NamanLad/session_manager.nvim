# Session Manager for neovim

`session_manager.nvim` is a simple session management plugin for Neovim. It allows you to
easily create and restore your work sessions, making it easier to switch between workflows
when working on large projects without losing your context. It integrates with
[Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for a seamless and interactive experience.

## Features

- **Session saving**: Use the `:SessionCreate` command to create a session out of the
  currently open buffers by specifying a name.
- **Session updating**: Use the `:SessionUpdateContent` command to select an existing
  session for this directory and update it with the currently open buffers.
- **Session restoring**: Use the `:SessionLoad` command to load all the available sessions
  you have created for this directory.
- **Session renaming**: Use the `:SessionUpdateName` command to rename one of the sessions
  for this directory.
- **Session deleting**: Use the `:SessionDelete` command to delete one of the sessions for
  this directory.

## See it in action

### Create a new session
https://github.com/user-attachments/assets/3826c476-4535-4274-aa34-af26a603353b

### Load a session
https://github.com/user-attachments/assets/97f2a59c-5e70-4b40-a062-ca6fc0f8648b

### Delete a session
https://github.com/user-attachments/assets/829defa8-7999-490d-a0d8-e45dc386c280

## Requirements

- Neovim 0.8+
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "NamanLad/session_manager.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("session_manager.manager").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "NamanLad/session_manager.nvim",
  requires = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("session_manager.manager").setup()
  end,
}
```

## Usage

### Commands

- **Save Session**: Use the `:SessionCreate` command to save currently open buffers into a session.
- **Load Session**: Use the `:SessionLoad` command to show all the available sessions for the current directory using [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and select one from the list to load.
- **Delete Session**: Use the `:SessionDelete` command to delete a session from the list of available sessions for the current directory.
- **Rename a session**: Use the `:SessionUpdateName` command rename a session from the list of available sessions for the current directory.
- **Update session buffers**: Use the `:SessionUpdateContent` command to update the definition of a session from the list of available sessions for the current directory.

## License

This plugin is licensed under the MIT License.
