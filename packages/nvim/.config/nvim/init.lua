---@diagnostic disable: undefined-global
vim.cmd("autocmd!")

-- 文字コード
vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

vim.wo.number = true -- 行数表示

vim.opt.title = true -- タイトルバーにファイル名表示
vim.opt.autoindent = true -- 自動インデント
vim.opt.smartindent = true -- 智能インデント
vim.opt.hlsearch = true -- 検索時にハイライト
vim.opt.backup = false -- バックアップファイルを作らない
vim.opt.showcmd = true -- コマンド入力中にコマンドを表示
vim.opt.cmdheight = 1 -- コマンドラインの高さ
vim.opt.laststatus = 2 -- ステータスラインを常に表示
vim.opt.expandtab = true -- タブをスペースに変換
vim.opt.scrolloff = 10 -- スクロール時のカーソル位置
vim.opt.shell = 'zsh' -- シェルの指
vim.opt.backupskip = { '/tmp/*', '/private/tmp/*' } -- バックアップ対象外
vim.opt.inccommand = 'split' -- 文字置換をインタラクティブに
vim.opt.ignorecase = true -- 検索で大文字小文字を区別しない
vim.opt.smarttab = true -- タブの挿入位置を自動調整
vim.opt.shiftwidth = 2 -- インデント幅
vim.opt.tabstop = 2 -- タブ幅
vim.opt.wrap = false -- 折り返しを無効
vim.opt.backspace = { 'start', 'eol', 'indent' } -- backspaceの設定
vim.opt.path:append { '**' } -- ファイル検索時のパス
vim.opt.wildignore:append { '*/node_modules/*' } -- ファイル検索時の除外パス
vim.opt.clipboard = 'unnamed' -- ヤンクをクリップボードに
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = '*',
  command = "set nopaste"
})

-- Add asterisks in block comments
vim.opt.formatoptions:append { 'r' }

-- theme
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.winblend = 0
vim.opt.wildoptions = 'pum'
vim.opt.pumblend = 5
-- vim.opt.background = 'dark'

-- kymap
vim.keymap.set('n', 'x', '"_x', { desc = '削除してレジスタに保存しない' })
vim.keymap.set('n', 'te', ':tabedit<Return>', { desc = '新しいタブを開く' })
vim.keymap.set('n', 'ss', ':split<Return><C-w>w', { desc = '水平分割' })
vim.keymap.set('n', 'sv', ':vsplit<Return><C-w>w', { desc = '垂直分割' })
vim.keymap.set('n', '<Space>', '<C-w>w', { desc = '次のウィンドウに移動' })
vim.keymap.set('', 'gh', '<C-w>h', { desc = '左のウィンドウに移動' })
vim.keymap.set('', 'gk', '<C-w>k', { desc = '上のウィンドウに移動' })
vim.keymap.set('', 'gj', '<C-w>j', { desc = '下のウィンドウに移動' })
vim.keymap.set('', 'gl', '<C-w>l', { desc = '右のウィンドウに移動' })
vim.keymap.set('n', '<Tab>', ':tabnext<CR>', { desc = '次のタブに移動' })
vim.keymap.set('n', '<S-Tab>', ':tabprevious<CR>', { desc = '前のタブに移動' })
vim.keymap.set('', 'gp', '<C-o>', { desc = '前のジャンプ位置に戻る' })

-- plugin
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  'Shatur/neovim-ayu',
  'nvim-lualine/lualine.nvim',
  'nvim-tree/nvim-web-devicons',
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'stevearc/dressing.nvim',
  'nvimdev/lspsaga.nvim',
  'ray-x/lsp_signature.nvim',
  'j-hui/fidget.nvim',
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    version = '1.*',
    build = 'cargo build --release',
  },
  'nvim-treesitter/nvim-treesitter',
  'zbirenbaum/copilot.lua',
  'stevearc/conform.nvim',
  'mfussenegger/nvim-lint',
  'akinsho/toggleterm.nvim',
  'kylechui/nvim-surround',
  'antosha417/nvim-lsp-file-operations',
  'akinsho/git-conflict.nvim',
  'mikavilpas/yazi.nvim',
  'lewis6991/gitsigns.nvim',
})

