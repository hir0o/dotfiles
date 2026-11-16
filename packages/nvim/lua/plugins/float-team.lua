return {
  'akinsho/toggleterm.nvim',
  cmd = 'ToggleTerm',
  keys = { { '<C-j>', mode = { 'n', 'i' } } },
  config = function()
    require("toggleterm").setup {
      open_mapping = [[<C-j>]],
      direction = 'float',
      float_opts = {
        border = 'rounded',
      },
    }
    -- vim.keymap.set({'n', 't'}, '<C-d>', '<cmd>ToggleTerm<CR>')
  end,
}
