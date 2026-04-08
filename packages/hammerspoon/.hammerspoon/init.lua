-- Focus follows mouse (hover to focus window)
local log = hs.logger.new("focus-follows-mouse", "info")

local DELAY = 0.0
local THROTTLE = 0.15 -- 最低呼び出し間隔(秒)。体感は即座のまま、CPU負荷を抑える
local EDGE_BUFFER = 16

local focusTimer = nil
local lastFocusedId = nil
local lastCheckTime = 0

local ignoredApps = {
    ["Raycast"] = true,
    ["Alfred"] = true,
    ["Spotlight"] = true,
}

local function focusWindowUnderCursor()
    local ok, err = pcall(function()
        local mousePos = hs.mouse.absolutePosition()
        local mouseScreen = hs.mouse.getCurrentScreen()
        if not mouseScreen then return end

        local windows = hs.fnutils.filter(hs.window.orderedWindows(), function(win)
            if win:screen() ~= mouseScreen then return false end
            local app = win:application()
            if not app then return false end
            return win:isVisible()
                and not win:isMinimized()
                and win:isStandard()
                and not ignoredApps[app:name()]
        end)

        for _, win in ipairs(windows) do
            local f = win:frame()
            if mousePos.x >= (f.x + EDGE_BUFFER)
                and mousePos.x <= (f.x + f.w - EDGE_BUFFER)
                and mousePos.y >= (f.y + EDGE_BUFFER)
                and mousePos.y <= (f.y + f.h - EDGE_BUFFER) then
                local id = win:id()
                if id ~= lastFocusedId then
                    lastFocusedId = id
                    win:focus()
                end
                return
            end
        end
    end)

    if not ok then
        log.e("error: " .. tostring(err))
    end
end

-- eventtap: マウス移動イベントでフォーカス (DELAY > 0 なら debounce)
FocusMouseWatcher = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(e)
    local flags = e:getFlags()
    if flags.cmd or flags.alt or flags.ctrl then return false end

    if DELAY > 0 then
        if focusTimer then
            focusTimer:stop()
            focusTimer:setNextTrigger(DELAY)
        else
            focusTimer = hs.timer.doAfter(DELAY, focusWindowUnderCursor)
        end
    else
        local now = hs.timer.secondsSinceEpoch()
        if now - lastCheckTime >= THROTTLE then
            lastCheckTime = now
            focusWindowUnderCursor()
        end
    end
    return false
end)
FocusMouseWatcher:start()

-- 設定ファイルの変更を検知して自動リロード
ConfigWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
            break
        end
    end
    if doReload then
        hs.reload()
    end
end)
ConfigWatcher:start()
hs.alert.show("Hammerspoon config loaded")

-- フォーカスが手動で変わった場合に追従
FocusWindowFilter = hs.window.filter.default
FocusWindowFilter:subscribe(
    hs.window.filter.windowFocused,
    function(win)
        if win then lastFocusedId = win:id() end
    end
)
