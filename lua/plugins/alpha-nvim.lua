return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-lua/plenary.nvim',
    { 'juansalvatore/git-dashboard-nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  config = function()
    -- Import alpha and dashboard
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Define custom icons
    local icons = {
      ui = {
        file = '',
        files = '',
        open_folder = '',
        config = '',
        close = '󰈆',
        git = '',
      },
    }

    local function whitespace_only(str)
      return str:match '^%s*$' ~= nil
    end

    local function pad(n)
      return { type = 'padding', val = n }
    end

    local function center_header(header)
      local lines = {}
      for line in string.gmatch(header, '[^\n]+') do
        table.insert(lines, line)
      end

      local width = vim.api.nvim_win_get_width(0) -- Get the width of the current window
      local padding = math.floor((width - #lines[1]) / 0.65) -- Calculate padding based on the first line length
      for i, line in ipairs(lines) do
        lines[i] = string.rep(' ', padding) .. line
      end

      return lines
    end

    local function format_git_header()
      local git_dashboard_raw = require('git-dashboard-nvim').setup {}
      local git_dashboard = {}
      for _, line in ipairs(git_dashboard_raw) do
        if not whitespace_only(line) then
          table.insert(git_dashboard, line)
        end
      end

      local git_repo = git_dashboard[1]
      local git_branch = git_dashboard[#git_dashboard]

      if git_repo == nil and git_branch == nil then
        return {
          type = 'text',
          val = '',
          opts = { position = 'center' },
        }
      end

      local git_branch_section = {
        type = 'text',
        val = ' ' .. git_repo .. ':' .. string.sub(git_branch, 5, #git_branch),
        opts = { position = 'center' },
      }

      return git_branch_section
    end

    -- Define custom header with ASCII art or any custom message
    local ascii_header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠔⣰⣿⣟⡽⢋⡴⣿⠏⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠹⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⡿⣡⠏⣴⡟⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢹⣿⣿⣿⣿⡿⠏⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⢾⣿⣿⡛⣰⡏⣼⣿⡇⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⣿⡿⢛⣻⡅⠀⡆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣠⡟⣸⣿⣿⢠⣿⠃⣿⣿⠃⣼⢿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⡇⢿⡇⣿⣿⠃⢠⡟⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⢃⣿⣿⠇⣾⡟⠀⣿⢇⣴⡄⢸⣿⣿⣿⡟⣿⣧⠘⣿⣿⡇⣿⢿⢻⣷⠸⣇⢿⣿⠀⠀⣧⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡼⢹⡿⢸⣿⡿⢸⠟⣵⡿⠈⠈⠿⣷⠈⣿⣿⣿⠆⢿⣷⢀⢻⣿⡆⢹⢼⣷⣿⢀⣿⡜⢿⠦⠀⠩⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣘⡇⣾⡿⢸⣿⡇⣠⡾⢋⣶⣦⠁⢒⡘⣷⡘⣿⣿⡄⣎⠻⡼⣧⡙⣿⣌⠘⣿⣿⢸⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣰⣿⡇⢿⣿⢸⡿⢰⣿⢡⣿⠉⣯⣄⠀⣷⣿⣿⣌⡻⢧⢹⣷⢆⣉⠠⠄⡀⢢⠹⣿⢸⣿⣿⣿⡿⢱⣦⠄⢠⣶⠀⠀⠀⠀
⠀⠀⣰⣿⣿⣷⢸⣿⠸⣿⢸⡏⣼⣿⠀⠟⠁⣸⣿⣿⣿⣿⣿⣷⣶⣴⡟⠿⡁⠀⢹⡎⢷⡹⢸⣿⣿⠟⣠⣿⠏⣼⢸⣿⡃⠀⠀⠀
⠀⠀⣿⣿⣿⣿⡆⣿⡇⣿⢸⣿⡸⣿⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⣷⡀⣸⣿⢸⣇⢸⣿⡏⣸⣿⡏⣸⣿⢸⣿⡇⠀⠀⠀
⠀⠀⢿⣿⣿⣿⣷⠸⣷⠸⢸⣿⣷⣮⣛⣛⣋⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠈⢠⣠⣿⡿⢸⠏⣾⢋⣴⣿⢋⣴⣿⣿⢸⣿⡏⡶⠀⠀
⠀⡇⣿⣿⣿⣿⣿⣧⡹⣧⠈⣿⣿⣿⣿⣿⣿⣿⡟⠛⠿⢿⣿⣿⣟⠿⣿⣿⣿⣿⡿⣣⡟⠜⣱⣿⠟⣴⣿⣿⣿⣿⢸⣿⠃⣟⡇⠀
⢘⠀⢻⣿⣿⣿⣿⣿⣷⡘⢆⠻⣿⣿⣿⣿⣿⡿⣰⣿⣿⡇⢿⣿⣿⣿⣶⣭⣭⣭⣾⡟⣠⣾⠟⣥⣿⣿⣿⣿⣿⡇⣼⡿⠸⣸⣿⡄
⢈⠀⠸⣿⣿⣿⣿⣿⣿⣿⡆⠀⠉⠻⢿⣿⣿⡇⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⢏⡼⢛⣴⣿⣿⣿⣿⣿⣿⣿⢁⣿⢡⢃⡏⣿⡇
⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⢰⡍⣛⠷⢭⣙⣛⣛⣸⣿⣿⣿⣿⣿⡿⠡⢊⣴⣿⣿⣿⣿⣿⣿⣿⣿⡏⣸⢇⡎⠘⡇⣿⡇
⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⠀⢠⣼⣷⣬⠛⣶⣬⣭⠉⡍⠋⠙⢩⣭⡍⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⢣⡎⠀⠀⢹⣿⠃
⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⢣⣾⣿⣿⢿⣿⣇⢹⣻⠿⢛⣩⣭⣝⠻⣿⢁⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠁⠀⠀⠀⣼⡟⠀
⠀⠀⠀⠀⠀⠀⠀⠛⢿⣿⢃⣿⣿⢿⣿⣿⣿⠉⡴⠉⠂⣾⣿⡿⢿⣷⡄⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⢀⠀⠂⠀⠟⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢸⣿⣿⣿⣮⣛⠿⢣⠰⠧⠾⣿⣿⣿⣿⣾⣿⢸⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⢀⠐⠀⡀⠄⠀⠀
		]]

    local git_branch_section = format_git_header()

    local custom_header = center_header(ascii_header)
    local header = { type = 'text', val = custom_header }

    local buttons = {
      type = 'group',
      val = {
        dashboard.button('e', icons.ui.file .. '  New file', '<cmd>new<CR>'),
        dashboard.button('o', icons.ui.files .. '  Recent Files', '<cmd>Telescope oldfiles<cr>'),
        -- dashboard.button('f', icons.ui.open_folder .. '  Explorer', '<cmd>Oil<cr>'),
        -- dashboard.button('c', icons.ui.config .. '  Neovim config', '<cmd>Oil /home/cafebabe/install/dotfiles/config/nvim<cr>'),
        -- dashboard.button('g', icons.ui.git .. '  Open Git', '<cmd>Neogit<CR>'),
        dashboard.button('l', '󰒲  Lazy', '<cmd>Lazy<cr>'),
        dashboard.button('q', icons.ui.close .. '  Quit NVIM', ':qa<CR>'),
      },
    }

    -- Custom footer showing number of plugins loaded
    local footer = {
      type = 'text',
      val = { '⚡' .. require('lazy').stats().loaded .. ' plugins loaded.' },
      opts = { position = 'center', hl = 'Comment' },
    }

    -- Custom section with a personal greeting
    local bottom_section = {
      type = 'text',
      val = "Hi eduardobattisti, It's" .. os.date ' %H:%M.' .. ' How are you doing today?',
      opts = { position = 'center' },
    }

    -- Setting up the alpha layout
    alpha.setup {
      layout = {
        pad(2),
        header,
        pad(1),
        git_branch_section,
        pad(2),
        buttons,
        pad(2),
        bottom_section,
        pad(2),
        footer,
      },
    }
  end,
}
