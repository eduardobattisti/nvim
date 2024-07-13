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

    vim.keymap.set('n', '<Leader>wp', window_picker.pick_window, { desc = 'Window Picker' })
  end,
}
