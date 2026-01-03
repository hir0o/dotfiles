local status, blink = pcall(require, "blink.cmp")
if (not status) then return end

blink.setup({
  -- 'default' for mappings similar to built-in completion
  -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
  -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
  keymap = { preset = 'default' },

  appearance = {
    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    -- Useful for when your theme doesn't support blink.cmp
    use_nvim_cmp_as_default = true,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    nerd_font_variant = 'mono'
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  completion = {
    menu = {
      border = 'rounded',
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
      window = {
        border = 'rounded',
      },
    },
  },

  signature = {
    enabled = true,
    window = {
      border = 'rounded',
    },
  },
})
