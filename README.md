# telescope-windowizer.nvim

Create new tmux window ready for edit your selected file inside vim.

`windowizer` creates a new tmux window with the selected file in a neovim instance. When you exit vim, the tmux window will be killed, returning to the previous window.

## Installation

You can install this pluging using your favorite pluging manager

**Packer**
```lua 
use({ "wesleimp/telescope-windowizer.nvim" })
```
**Plug**
```vim 
Plug 'wesleimp/telescope-windowizer.nvim'
```

## Usage

### Setup

```lua
require("telescope").load_extension("windowizer")
```

### Configuration

This extension can be configured using `extensions` field inside Telescope setup function

```lua
require("telescope").setup({
  extensions = {
    windowizer = {
      find_cmd = "rg" -- find command. Available options [ find | fd | rg ] (defaults to "fd")
    }
  },
})
```

### Available commands

Using vim command

```vim
:Telescope windowizer

" using lua function
lua require("telescope").extensions.windowizer.windowizer()
```

## LICENSE

[MIT](./LICENSE)
