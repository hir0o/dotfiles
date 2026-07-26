local obj = {
	name = "Kokukoku",
	version = "0.9.0",
	author = "tadashi-aikawa",
	license = "MIT - https://github.com/tadashi-aikawa/kokukoku/blob/main/LICENSE",
	homepage = "https://github.com/tadashi-aikawa/kokukoku",
}

local previousState = _G.__kokukoku
if previousState and previousState.teardown then
	previousState.teardown()
end

local timerEngineModule = nil
local uiPanelModule = nil
local alertModule = nil
local persistenceModule = nil

local timerEngine = nil
local uiPanel = nil
local alert = nil
local persistence = nil
local hotkey = nil

local function resourcePath(fileName)
	if not hs or not hs.spoons or not hs.spoons.resourcePath then
		error("[kokukoku] hs.spoons.resourcePath is not available")
	end

	local path = hs.spoons.resourcePath(fileName)
	if not path then
		error("[kokukoku] failed to resolve Spoon resource: " .. tostring(fileName))
	end
	return path
end

local function mergeTable(defaults, overrides)
	local merged = {}
	for k, v in pairs(defaults) do
		merged[k] = v
	end
	if overrides then
		for k, v in pairs(overrides) do
			merged[k] = v
		end
	end
	return merged
end

local function normalizeConfig(selfOrConfig, maybeConfig)
	if maybeConfig ~= nil then
		return maybeConfig
	end
	if selfOrConfig == nil or selfOrConfig == obj then
		return {}
	end
	return selfOrConfig
end

function obj:setup(config)
	config = normalizeConfig(self, config)

	obj:teardown()

	if timerEngineModule == nil then
		timerEngineModule = dofile(resourcePath("timer_engine.lua"))
	end
	if uiPanelModule == nil then
		uiPanelModule = dofile(resourcePath("ui_panel.lua"))
	end
	if alertModule == nil then
		alertModule = dofile(resourcePath("alert.lua"))
	end
	if persistenceModule == nil then
		persistenceModule = dofile(resourcePath("persistence.lua"))
	end

	persistence = persistenceModule.new(config.persistence or {})

	local savedState = persistence.load()

	timerEngine = timerEngineModule.new(mergeTable(config, {
		initialState = savedState,
		onStateChange = function(state)
			persistence.save(state)
		end,
		onTick = function(state)
			if uiPanel then
				uiPanel.update(state)
			end
		end,
		onAlert = function(state)
			if alert then
				alert.check(state)
			end
		end,
	}))

	alert = alertModule.new(config.alert or {})

	uiPanel = uiPanelModule.new(mergeTable(config.ui or {}, {
		projects = config.projects,
		breakItem = config.breakItem,
		versionText = "v" .. obj.version,
		keymap = config.keymap,
		onProjectSelect = function(projectId)
			timerEngine.startProject(projectId)
		end,
		onBreak = function()
			timerEngine.startBreak()
		end,
		onReset = function()
			timerEngine.reset()
		end,
		onSetAccumulated = function(projectId, seconds)
			timerEngine.setAccumulated(projectId, seconds)
		end,
		onSetContinuous = function(seconds)
			timerEngine.setContinuousElapsed(seconds)
		end,
		getState = function()
			return timerEngine.getState()
		end,
	}))

	if config.hotkey then
		hotkey = hs.hotkey.bind(config.hotkey.modifiers, config.hotkey.key, function()
			uiPanel.toggle()
		end)
	end

	return obj
end

function obj:teardown()
	if hotkey then
		hotkey:delete()
		hotkey = nil
	end
	if uiPanel and uiPanel.teardown then
		uiPanel.teardown()
	end
	if alert and alert.teardown then
		alert.teardown()
	end
	if timerEngine and timerEngine.teardown then
		timerEngine.teardown()
	end
	if persistence and persistence.teardown then
		persistence.teardown()
	end
	uiPanel = nil
	alert = nil
	timerEngine = nil
	persistence = nil

	return obj
end

_G.__kokukoku = {
	teardown = function()
		obj:teardown()
	end,
}

return obj
