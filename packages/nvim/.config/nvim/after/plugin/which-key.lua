local status, wk = pcall(require, "which-key")
if (not status) then return end

wk.setup({
  preset = "modern",
  delay = 300,
  icons = {
    mappings = true,
  },
})
