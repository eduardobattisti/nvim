return {
  'rcarriga/nvim-notify',
  opts = {},
  config = function(_, opts)
    local notify = require 'notify'
    notify.setup(opts)

    vim.notify = notify
    vim.notify('This is an info message 1', 'info')
    vim.notify('This is an info message 2', 'info')
    vim.notify('This is an info message 3', 'info')
    vim.notify('This is an info message 4', 'info')
    vim.notify('This is an info message 5', 'info')
    vim.notify('This is an info message 6', 'info')
  end,
}
