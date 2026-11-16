return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = 'Telescope',
  keys = {
    {
      ';f',
      function()
        require("telescope.builtin").find_files({
          no_ignore = true,
          hidden = true
        })
      end,
      desc = 'ファイルを検索',
    },
    { ';r', function() require("telescope.builtin").live_grep() end, desc = 'テキストをGrepで検索' },
    { '\\\\', function() require("telescope.builtin").buffers() end, desc = 'バッファ一覧を表示' },
    { ';t', function() require("telescope.builtin").help_tags() end, desc = 'ヘルプタグを検索' },
    { ';;', function() require("telescope.builtin").resume() end, desc = '前回のTelescopeを再開' },
    { ';e', function() require("telescope.builtin").diagnostics() end, desc = '診断情報を表示' },
    -- コマンドパレット (VS Code の Ctrl+Shift+P 相当)
    {
      '<C-S-p>',
      function()
        require("telescope.builtin").keymaps(require('telescope.themes').get_dropdown({
          layout_config = {
            width = 0.7,
            height = 0.6
          },
          prompt_title = "コマンドパレット",
        }))
      end,
      desc = 'コマンドパレットを開く',
    },
  },
  config = function()
    local actions = require('telescope.actions')

    require("telescope").setup {
      defaults = {
        mappings = {
          n = {
            ["q"] = actions.close
          },
        },
        file_ignore_patterns = { "node%_modules/.*", ".git/.*", ".next/.*", "__resource/.*" }
      },
    }
  end,
}
