require('neo-tree').setup({
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = true,
  window = {
    width = 30,
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    window = {
      position = "float",         -- ← ここ！
      popup = {
        size      = { width = "60%", height = "80%" }, --% か行数/列数
        position  = "50%",        -- 画面中央（数値や table も可）
        border    = "rounded",    -- or "single", "double", …
      }
    },
    follow_current_file = true,
    use_libuv_file_watcher = true,
  },
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1,
    },
  },
})

vim.keymap.set('n', 'ge', ':Neotree filesystem<CR>', { desc = 'ファイルツリーを開く' })
