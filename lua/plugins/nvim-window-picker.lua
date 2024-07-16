return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  event = 'VeryLazy',
  version = '2.*',
  opts = {},
  config = function()
    local window_picker = require 'window-picker'

    window_picker.setup {
      hint = 'floating-big-letter',
    }

    vim.keymap.set('n', '<Leader>wp', function()
      local window_id = require('window-picker').pick_window()

      if window_id then
        vim.api.nvim_set_current_win(window_id)
      else
        vim.notify('No window selected', 'info')
      end
    end, { desc = 'Window Picker' })
  end,
}
