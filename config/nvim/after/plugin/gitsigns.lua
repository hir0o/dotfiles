local status, gitsigns = pcall(require, "gitsigns")
if (not status) then return end

gitsigns.setup({
  signs = {
    add = { text = '┃' },
    change = { text = '┃' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' }
  },
  signs_staged = {
    add = { text = '┃' },
    change = { text = '┃' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
    ignore_whitespace = false,
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil,
  max_file_length = 40000,
})

-- Navigation
vim.keymap.set('n', ']c', function()
  if vim.wo.diff then return ']c' end
  vim.schedule(function() gitsigns.nav_hunk('next') end)
  return '<Ignore>'
end, { expr = true, desc = 'Next hunk' })

vim.keymap.set('n', '[c', function()
  if vim.wo.diff then return '[c' end
  vim.schedule(function() gitsigns.nav_hunk('prev') end)
  return '<Ignore>'
end, { expr = true, desc = 'Previous hunk' })

-- Actions
vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage hunk' })
vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset hunk' })
vim.keymap.set('n', 'mR', gitsigns.reset_hunk, { desc = 'Reset hunk' })
vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = 'Stage hunk' })
vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = 'Reset hunk' })
vim.keymap.set('v', 'mR', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = 'Reset hunk' })
vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Stage buffer' })
vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Undo stage hunk' })
vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Reset buffer' })
vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview hunk' })
vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'Blame line' })
vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle line blame' })
vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff this' })
vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = 'Diff this ~' })
vim.keymap.set('n', '<leader>td', gitsigns.toggle_deleted, { desc = 'Toggle deleted' })

-- Text object
vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
