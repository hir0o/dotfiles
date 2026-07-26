local status, sidekick = pcall(require, "sidekick")
if (not status) then return end

-- sidekick.nvimはcopilot.luaと併用します
-- copilot.lua: インライン補完（as-you-typeの素早い提案）
-- sidekick.nvim: より大規模なリファクタリングや複数行の変更（NES機能）

sidekick.setup({
  -- Next Edit Suggestions設定
  nes = {
    enabled = true,
    auto_suggest = true,
    debounce = 100, -- 100msに短縮（より反応的に）
    clear = {
      events = { "TextChangedI", "InsertEnter" },
      esc = true, -- Escキーでクリア
    },
    diff = {
      inline = "words", -- 単語単位でインライン表示
    },
  },
  -- サイン（UIフィードバック）
  signs = {
    enabled = true,
    icon = " ", -- Copilotアイコン
  },
  -- AI CLIターミナル設定
  cli = {
    enabled = true,
    watch = true, -- AI作成ファイルの自動リロード
    picker = "snacks", -- snacks/telescope/fzf-lua
    mux = {
      backend = "zellij", -- またはtmux
      enabled = true,
      create = "terminal", -- terminal/window/split
    },
    win = {
      layout = "right", -- float/left/bottom/top/right
      split = { width = 80 },
    },
  },
  -- Copilot LSP統合
  copilot = {
    status = {
      enabled = true,
      level = vim.log.levels.WARN,
    },
  },
})

-- キーマップを手動で設定
local opts = { noremap = true, silent = true }

-- Next Edit Suggestions（改善版：nes_jump_or_applyを使用）
vim.keymap.set({ 'n', 'i' }, '<Tab>', function()
  if not require("sidekick").nes_jump_or_apply() then
    return '<Tab>'
  end
end, vim.tbl_extend('force', opts, { expr = true, desc = 'Sidekick: NESジャンプ/適用' }))

-- NESハンク操作
vim.keymap.set('n', '<M-}>', function()
  require('sidekick.nes').next_hunk()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: 次のハンク' }))

vim.keymap.set('n', '<M-{>', function()
  require('sidekick.nes').prev_hunk()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: 前のハンク' }))

vim.keymap.set('n', '<M-a>', function()
  require('sidekick.nes').accept_hunk()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: ハンクを受け入れ' }))

vim.keymap.set('n', '<Esc>', function()
  require('sidekick.nes').clear()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: NESをクリア' }))

-- AI CLI
vim.keymap.set({ 'n', 'i', 'v' }, '<C-.>', function()
  require('sidekick.cli').toggle()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: CLI切り替え' }))

vim.keymap.set('n', '<leader>aa', function()
  require('sidekick.cli').toggle()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: CLIを開く/閉じる' }))

vim.keymap.set('n', '<leader>as', function()
  require('sidekick.cli').select()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: AIツール選択' }))

vim.keymap.set('n', '<leader>ap', function()
  require('sidekick.cli').prompt()
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: プロンプト選択' }))

vim.keymap.set('n', '<leader>at', function()
  require('sidekick.cli').send({ msg = "{this}" })
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: カーソル位置を送信' }))

vim.keymap.set('n', '<leader>af', function()
  require('sidekick.cli').send({ msg = "{file}" })
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: ファイル全体を送信' }))

vim.keymap.set('v', '<leader>av', function()
  require('sidekick.cli').send({ msg = "{selection}" })
end, vim.tbl_extend('force', opts, { desc = 'Sidekick: 選択範囲を送信' }))
