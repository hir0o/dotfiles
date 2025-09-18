vim.opt.termguicolors = true
require('ayu').colorscheme()

local function set_transparent()
  local transparent_groups = {
    "Normal", "NormalNC", "SignColumn", "EndOfBuffer",
    "LineNr", "CursorLineNr", "StatusLine", "TabLineFill",
    "MsgArea", "TermNormal", "WinSeparator",
  }
  for _, grp in ipairs(transparent_groups) do
    vim.cmd(("hi %s ctermbg=NONE guibg=NONE"):format(grp))
  end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = set_transparent,
})