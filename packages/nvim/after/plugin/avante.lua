local status, avante = pcall(require, "avante")
if (not status) then return end

avante.setup({
  provider = "claude",
  mode = "agentic",
  providers = {
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-sonnet-4-20250514",
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 20480,
      },
    },
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    minimize_diff = true,
    enable_token_counting = true,
  },
  windows = {
    position = "right",
    wrap = true,
    width = 30,
    sidebar_header = {
      enabled = true,
      align = "center",
      rounded = true,
    },
  },
})

-- render-markdown setup for Avante filetype
local rm_status, render_markdown = pcall(require, "render-markdown")
if rm_status then
  render_markdown.setup({
    file_types = { "markdown", "Avante" },
  })
end
