local status, noice = pcall(require, "noice")
if (not status) then return end

noice.setup({
  lsp = {
    -- fidget.nvim を使っているので progress は無効化
    progress = { enabled = false },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    hover = { enabled = true },
    signature = {
      -- lsp_signature.nvim を使っているので無効化
      enabled = false,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    lsp_doc_border = true,
  },
  routes = {
    -- 短い通知メッセージをミニビューで表示
    {
      filter = {
        event = "msg_show",
        kind = "",
        find = "written",
      },
      opts = { skip = true },
    },
  },
  views = {
    cmdline_popup = {
      position = {
        row = 5,
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
    },
  },
})

-- nvim-notify の設定
local notify_status, notify = pcall(require, "notify")
if notify_status then
  notify.setup({
    background_colour = "#000000",
    timeout = 3000,
    max_width = 60,
    render = "compact",
    stages = "fade",
  })
end
