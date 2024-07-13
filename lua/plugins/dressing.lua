return {
  'stevearc/dressing.nvim',
  opts = {
    input = {
      -- Set to true to enable the floating window for command inputs
      enabled = true,
      -- Configure additional options for the floating window
      default_prompt = 'Command: ',
      prompt_align = 'center',
      border = 'rounded',
      win_options = {
        winblend = 10,
        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
      },
    },
  },
}
