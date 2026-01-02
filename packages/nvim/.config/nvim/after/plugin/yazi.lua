local status, yazi = pcall(require, "yazi")
if (not status) then return end

yazi.setup({
  open_for_directories = false,
  floating_window_scaling_factor = 0.9,
  keymaps = {
    show_help = "<f1>",
  }
})

vim.keymap.set('n', '<leader>-', '<cmd>Yazi<cr>', { desc = "Open yazi at the current file" })
vim.keymap.set('v', '<leader>-', '<cmd>Yazi<cr>', { desc = "Open yazi at the current file" })