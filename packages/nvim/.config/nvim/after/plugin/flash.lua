local status, flash = pcall(require, "flash")
if (not status) then return end

flash.setup({
  -- ラベル設定
  labels = "asdfghjklqwertyuiopzxcvbnm",
  -- 検索設定
  search = {
    multi_window = true,
    forward = true,
    wrap = true,
    mode = "exact",
  },
  -- ジャンプ設定
  jump = {
    jumplist = true,
    pos = "start",
    history = false,
    register = false,
    nohlsearch = false,
  },
  -- モード設定
  modes = {
    search = {
      enabled = true,
    },
    char = {
      enabled = true,
      jump_labels = true,
    },
  },
})

-- キーマップ設定
local opts = { noremap = true, silent = true }

-- ノーマルモード、ビジュアルモード、オペレータペンディングモードでのキーマップ
vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  flash.jump()
end, vim.tbl_extend('force', opts, { desc = 'Flash: ジャンプ' }))

vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  flash.treesitter()
end, vim.tbl_extend('force', opts, { desc = 'Flash: Treesitter選択' }))

vim.keymap.set('o', 'r', function()
  flash.remote()
end, vim.tbl_extend('force', opts, { desc = 'Flash: リモート操作' }))

vim.keymap.set({ 'o', 'x' }, 'R', function()
  flash.treesitter_search()
end, vim.tbl_extend('force', opts, { desc = 'Flash: Treesitter検索' }))

-- 検索時にフラッシュを切り替え
vim.keymap.set({ 'c' }, '<c-s>', function()
  flash.toggle()
end, vim.tbl_extend('force', opts, { desc = 'Flash: 検索モード切り替え' }))
