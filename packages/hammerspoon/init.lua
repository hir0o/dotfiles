hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.jinrai = {
  url = "https://github.com/tadashi-aikawa/jinrai",
  desc = "JINRAI Spoon repository",
  branch = "spoons",
}

spoon.SpoonInstall:andUse("Jinrai", {
  repo = "jinrai",
  fn = function(jinrai)
    jinrai:setup({
      macosNativeTabs = {},
      focus_border = {},
      window_hints = {
        hotkey = {
          modifiers = { "alt" },
          key = "f",
        },
        occlusion = {
          preview = {
            enabled = false,
          },
        },
        hint = {
          prefixOverrides = {
            {
              match = { bundleID = "md.obsidian" },
              prefix = "O",
            },
            {
              match = { bundleID = "com.google.Chrome" },
              prefix = "C",
            },
            {
              match = { bundleID = "com.mitchellh.ghostty" },
              prefix = "G",
            },
            {
              match = { bundleID = "com.cmuxterm.app" },
              prefix = "T",
            },
          },
        },
        navigation = {
          direction = {
            hints = {
              keys = {
                left = "h",
                down = "j",
                up = "k",
                right = "l",
                upLeft = "y",
                upRight = "u",
                downLeft = "b",
                downRight = "n",
              },
            },
          },
        },
      },
      focus_back = {
        hotkey = {
          modifiers = { "alt" },
          key = "tab",
        },
      },
    })
  end,
})

