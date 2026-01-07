require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'ayu_dark',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {
      -- Copilotステータス
      {
        function()
          return " "
        end,
        color = function()
          local status = require("sidekick.status").get()
          if not status then
            return nil
          end
          return status.busy and "DiagnosticWarn" or "Special"
        end,
        cond = function()
          return require("sidekick.status").get() ~= nil
        end,
      },
      -- sidekick CLIセッション数
      {
        function()
          local sessions = require("sidekick.status").cli()
          return " " .. #sessions
        end,
        cond = function()
          return #require("sidekick.status").cli() > 0
        end,
      },
      'encoding',
      'fileformat',
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

