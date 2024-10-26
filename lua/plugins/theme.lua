return {
  'ribru17/bamboo.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    local bamboo = require 'bamboo'

    bamboo.setup {}
    bamboo.load()
  end,
}
