return {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(count, level, _, _)
        local icon = level:match 'error' and ' ' or ' '
        return ' ' .. icon .. count
      end,
      separator_style = 'slant',
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'File Explorer',
          separator = false,
          text_align = 'center',
        },
      },
    },
  },
  keys = {
    { '<Tab>', ':BufferLineCycleNext<CR>', { desc = 'Navigate to next buffer' } },
    { '<S-Tab>', ':BufferLineCyclePrev<CR>', { desc = 'Navigate to previous buffer' } },
    { '<Leader>x', ':bd<CR>', desc = 'which_key_ignore' },
  },
}
