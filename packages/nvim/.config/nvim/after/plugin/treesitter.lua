require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'typescript',
    'tsx',
    'css',
  },
  highlight = {
    enable = true,
  },
})

