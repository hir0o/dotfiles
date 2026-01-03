local status, telescope = pcall(require, "telescope")
if (not status) then return end
local actions = require('telescope.actions')
local builtin = require("telescope.builtin")

local function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local fb_actions = require "telescope".extensions.file_browser.actions

telescope.setup {
  defaults = {
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
    file_ignore_patterns = { "node%_modules/.*", ".git/.*" }
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = false,
      mappings = {
        -- your custom insert mode mappings
        ["i"] = {
          ["<C-w>"] = function() vim.cmd('normal vbd') end,
        },
        ["n"] = {
          -- your custom normal mode mappings
          ["N"] = fb_actions.create,
          ["h"] = fb_actions.goto_parent_dir,
          ["/"] = function()
            vim.cmd('startinsert')
          end
        },
      },
    },
  },
}

telescope.load_extension("file_browser")

vim.keymap.set('n', ';f',
  function()
    builtin.find_files({
      no_ignore = false,
      hidden = true
    })
  end, { desc = 'ファイルを検索' })

vim.keymap.set('n', ';r', function()
  builtin.live_grep()
end, { desc = 'テキストをGrepで検索' })

vim.keymap.set('n', '\\\\', function()
  builtin.buffers()
end, { desc = 'バッファ一覧を表示' })

vim.keymap.set('n', ';t', function()
  builtin.help_tags()
end, { desc = 'ヘルプタグを検索' })

vim.keymap.set('n', ';;', function()
  builtin.resume()
end, { desc = '前回のTelescopeを再開' })

vim.keymap.set('n', ';e', function()
  builtin.diagnostics()
end, { desc = '診断情報を表示' })

vim.keymap.set("n", "sf", function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 }
  })
end, { desc = 'ファイルブラウザを開く' })

-- コマンドパレット (VS Code の Ctrl+Shift+P 相当)
vim.keymap.set('n', '<C-S-p>', function()
  builtin.keymaps(require('telescope.themes').get_dropdown({
    layout_config = {
      width = 0.7,
      height = 0.6
    },
    prompt_title = "コマンドパレット",
  }))
end, { desc = 'コマンドパレットを開く' })

