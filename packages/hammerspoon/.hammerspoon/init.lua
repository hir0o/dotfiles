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

spoon.SpoonInstall.repos.kokukoku = {
  url = "https://github.com/tadashi-aikawa/kokukoku",
  desc = "KOKUKOKU Spoon repository",
  branch = "spoons",
}

-- Kokukoku のプロジェクト一覧を動的に追加・削除できるようにする
local kokukokuProjectsPath = os.getenv("HOME") .. "/.kokukoku/projects.json"
local kokukokuDefaultIcon = "📋"
local kokukokuDefaultProjects = {
  { id = "dev", name = "開発", icon = "💻" },
  { id = "input", name = "インプット", icon = "📚" },
  { id = "setup", name = "環境構築", icon = "🛠" },
}

local function loadKokukokuProjects()
  local file = io.open(kokukokuProjectsPath, "r")
  if not file then
    return kokukokuDefaultProjects
  end
  local content = file:read("*a")
  file:close()
  local ok, data = pcall(hs.json.decode, content)
  if not ok or type(data) ~= "table" or #data == 0 then
    return kokukokuDefaultProjects
  end
  return data
end

local function saveKokukokuProjects(projects)
  local dir = kokukokuProjectsPath:match("(.+)/[^/]+$")
  if dir then
    os.execute('mkdir -p "' .. dir .. '"')
  end
  local file = io.open(kokukokuProjectsPath, "w")
  if file then
    file:write(hs.json.encode(projects, true))
    file:close()
  end
end

local kokukokuProjects = loadKokukokuProjects()

local function setupKokukoku()
  if not spoon.Kokukoku then
    return
  end
  spoon.Kokukoku:setup({
    projects = kokukokuProjects,
    breakItem = { name = "休憩", icon = "☕" },
    hotkey = { modifiers = { "alt" }, key = "t" },
  })
end

spoon.SpoonInstall:andUse("Kokukoku", {
  repo = "kokukoku",
  fn = function()
    setupKokukoku()
  end,
})

-- Alt+Shift+t: プロジェクトの追加・削除 chooser
local function buildKokukokuChoices(query)
  local trimmed = (query or ""):match("^%s*(.-)%s*$")
  local choices = {}
  local exists = false
  for _, p in ipairs(kokukokuProjects) do
    if p.id == trimmed or p.name == trimmed then
      exists = true
    end
    table.insert(choices, {
      text = (p.icon or "") .. " " .. p.name,
      subText = "選択して削除",
      kind = "delete",
      id = p.id,
    })
  end
  if trimmed ~= "" and not exists then
    table.insert(choices, 1, {
      text = "➕ 追加: " .. trimmed,
      subText = "新しいプロジェクトを追加",
      kind = "add",
      newId = trimmed,
    })
  end
  return choices
end

local function showKokukokuProjectChooser()
  local chooser
  chooser = hs.chooser.new(function(choice)
    if not choice then
      return
    end
    if choice.kind == "add" then
      table.insert(kokukokuProjects, {
        id = choice.newId,
        name = choice.newId,
        icon = kokukokuDefaultIcon,
      })
      saveKokukokuProjects(kokukokuProjects)
      setupKokukoku()
      hs.alert.show("追加: " .. choice.newId)
    elseif choice.kind == "delete" then
      local newList = {}
      for _, p in ipairs(kokukokuProjects) do
        if p.id ~= choice.id then
          table.insert(newList, p)
        end
      end
      kokukokuProjects = newList
      saveKokukokuProjects(kokukokuProjects)
      setupKokukoku()
      hs.alert.show("削除: " .. choice.id)
    end
  end)
  chooser:placeholderText("IDを入力して追加 / 選択して削除")
  chooser:choices(buildKokukokuChoices(""))
  chooser:queryChangedCallback(function(query)
    chooser:choices(buildKokukokuChoices(query))
  end)
  chooser:show()
end

hs.hotkey.bind({ "alt", "shift" }, "t", showKokukokuProjectChooser)

local pinnedWindows = {}

local function makePinBorder(frame)
  local canvas = hs.canvas.new({ x = frame.x, y = frame.y, w = frame.w, h = frame.h })
  canvas:level(hs.canvas.windowLevels.overlay)
  canvas:behavior({ "canJoinAllSpaces" })
  canvas:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = { red = 0.95, green = 0.25, blue = 0.25, alpha = 0.95 },
    strokeWidth = 3,
    roundedRectRadii = { xRadius = 8, yRadius = 8 },
    frame = { x = 1.5, y = 1.5, w = frame.w - 3, h = frame.h - 3 },
  })
  canvas:show()
  return canvas
end

local function syncPinBorder(win)
  local entry = pinnedWindows[win:id()]
  if not entry then return end
  local f = win:frame()
  entry.canvas:frame({ x = f.x, y = f.y, w = f.w, h = f.h })
  entry.canvas[1].frame = { x = 1.5, y = 1.5, w = f.w - 3, h = f.h - 3 }
end

local function unpinWindow(id)
  local entry = pinnedWindows[id]
  if not entry then return end
  entry.canvas:delete()
  pinnedWindows[id] = nil
end

local function raisePinnedWindows()
  for _, entry in pairs(pinnedWindows) do
    if entry.win and entry.win:isStandard() and not entry.win:isMinimized() then
      pcall(function()
        entry.win:raise()
      end)
    end
  end
end

local pinWindowFilter = hs.window.filter.default
pinWindowFilter:subscribe(hs.window.filter.windowMoved, syncPinBorder)
pinWindowFilter:subscribe(hs.window.filter.windowDestroyed, function(win)
  unpinWindow(win:id())
end)
pinWindowFilter:subscribe(hs.window.filter.windowFocused, function()
  raisePinnedWindows()
end)

hs.hotkey.bind({ "alt" }, "p", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local id = win:id()

  if pinnedWindows[id] then
    unpinWindow(id)
    hs.alert.show("Unpinned")
  else
    pinnedWindows[id] = { win = win, canvas = makePinBorder(win:frame()) }
    hs.alert.show("Pinned")
  end
end)

