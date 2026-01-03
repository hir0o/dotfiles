local status, telescope = pcall(require, "telescope")
if (not status) then return end
local actions = require('telescope.actions')
local builtin = require("telescope.builtin")

telescope.setup {
  defaults = {
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
    file_ignore_patterns = { "node%_modules/.*", ".git/.*" }
  },
}

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

