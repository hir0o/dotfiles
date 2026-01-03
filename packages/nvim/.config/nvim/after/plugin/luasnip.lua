local status, luasnip = pcall(require, "luasnip")
if (not status) then return end

-- LuaSnip の基本設定
luasnip.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
})

-- キーマップ設定
-- 注: <Tab> は copilot.lua で使用しているため、別のキーを使用
vim.keymap.set({"i", "s"}, "<C-l>", function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end, { silent = true, desc = "LuaSnip: 展開またはジャンプ" })

vim.keymap.set({"i", "s"}, "<C-h>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end, { silent = true, desc = "LuaSnip: 前にジャンプ" })

vim.keymap.set("i", "<C-j>", function()
  if luasnip.choice_active() then
    luasnip.change_choice(1)
  end
end, { silent = true, desc = "LuaSnip: 次の選択肢" })
