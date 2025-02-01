return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      disabled_filetypes = {
        statusline = { 'neo-tree', 'alpha', 'toggleterm' },
      },
    },
  },
}
