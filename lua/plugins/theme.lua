return {
  'catppuccin/nvim',
  priority = 1000,
  lazy = false,
  config = function()
    vim.cmd.colorscheme 'catppuccin-frappe'
  end,
}
