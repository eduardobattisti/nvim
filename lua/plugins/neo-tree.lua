return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<Leader>e', ':Neotree toggle<CR>', { desc = 'NeoTree toggle' } },
  },
  opts = {
    close_if_last_window = false,
    enable_git_status = true,
    enable_diagnostics = true,
    sources = { 'filesystem', 'buffers', 'git_status' },
    source_selector = {
      winbar = true,
      content_layout = 'center',
      sources = {
        { source = 'filesystem', display_name = '󰉋 File' },
        { source = 'buffers', display_name = '󰈔 Bufs' },
        { source = 'diagnostics', display_name = '󰒡 Diagnostic' },
        { source = 'git_status', display_name = '󰊤 Git' },
      },
    },
    window = {
      width = 40,
      mappings = {
        ['<Tab>'] = 'next_source',
        ['<S-Tab>'] = 'prev_source',
      },
    },
    filesystem = {
      window = {
        mappings = {
          ['<Leader>o'] = 'close_window',
        },
      },
    },
  },
}
