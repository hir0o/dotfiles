return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  config = function()
    require("yazi").setup({
      open_for_directories = true,
      floating_window_scaling_factor = 0.9,
      keymaps = {
        show_help = "<f1>",
      }
    })

    vim.keymap.set('n', '<leader>-', '<cmd>Yazi<cr>', { desc = "Open yazi at the current file" })
    vim.keymap.set('v', '<leader>-', '<cmd>Yazi<cr>', { desc = "Open yazi at the current file" })
  end,
}
