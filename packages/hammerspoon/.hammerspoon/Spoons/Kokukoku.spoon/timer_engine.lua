local M = {}

local function resourcePath(fileName)
	if not hs or not hs.spoons or not hs.spoons.resourcePath then
		error("[kokukoku.timer_engine] hs.spoons.resourcePath is not available")
	end

	local path = hs.spoons.resourcePath(fileName)
	if not path then
		error("[kokukoku.timer_engine] failed to resolve Spoon resource: " .. tostring(fileName))
	end
	return path
end

local timerEngineConfig = nil
local function loadConfig()
	if timerEngineConfig == nil then
		timerEngineConfig = dofile(resourcePath("timer_engine_config.lua"))
	end
	return timerEngineConfig
end

local function formatTime(seconds)
	if seconds == nil or seconds < 0 then
		return "00:00:00"
	end
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function findProject(projects, projectId)
	for _, project in ipairs(projects) do
		if project.id == projectId then
			return project
		end
	end
	return nil
end

function M.new(options)
	local config = loadConfig().build(options)

	local state = {
		accumulated = {},
		activeProjectId = nil,
		activeStartedAt = nil,
		continuousElapsedBase = 0,
		continuousStartedAt = nil,
		lastResetAt = os.time(),
	}

	if config.initialState then
		local init = config.initialState
		if init.accumulated then
			for k, v in pairs(init.accumulated) do
				state.accumulated[k] = v
			end
		end
		if init.activeProjectId then
			state.activeProjectId = init.activeProjectId
		end
		if init.activeStartedAt then
			state.activeStartedAt = init.activeStartedAt
		end
		if type(init.continuousElapsedBase) == "number" and init.continuousElapsedBase >= 0 then
			state.continuousElapsedBase = math.floor(init.continuousElapsedBase)
		end
		if init.continuousStartedAt then
			state.continuousStartedAt = init.continuousStartedAt
		end
		if init.lastResetAt then
			state.lastResetAt = init.lastResetAt
		end
	end

	local tickTimer = nil

	local function currentElapsed()
		if state.activeProjectId and state.activeStartedAt then
			return os.time() - state.activeStartedAt
		end
		return 0
	end

	local function currentContinuousElapsed()
		local base = state.continuousElapsedBase or 0
		if state.continuousStartedAt then
			return base + (os.time() - state.continuousStartedAt)
		end
		return base
	end

	local function accumulatedFor(projectId)
		local base = state.accumulated[projectId] or 0
		if state.activeProjectId == projectId and state.activeStartedAt then
			return base + (os.time() - state.activeStartedAt)
		end
		return base
	end

	local function finalizeActive()
		if state.activeProjectId and state.activeStartedAt then
			local elapsed = os.time() - state.activeStartedAt
			state.accumulated[state.activeProjectId] = (state.accumulated[state.activeProjectId] or 0) + elapsed
		end
		state.activeProjectId = nil
		state.activeStartedAt = nil
	end

	local function notifyStateChange()
		if config.onStateChange then
			config.onStateChange(state)
		end
	end

	local function startProject(projectId)
		local project = findProject(config.projects, projectId)
		if not project then
			return
		end

		finalizeActive()

		state.activeProjectId = projectId
		state.activeStartedAt = os.time()
		if not state.continuousStartedAt then
			state.continuousStartedAt = os.time()
		end

		notifyStateChange()
	end

	local function startBreak()
		finalizeActive()
		state.continuousElapsedBase = 0
		state.continuousStartedAt = nil
		notifyStateChange()
	end

	local function reset()
		finalizeActive()
		state.accumulated = {}
		state.continuousElapsedBase = 0
		state.continuousStartedAt = nil
		state.lastResetAt = os.time()
		notifyStateChange()
	end

	local function setAccumulated(projectId, seconds)
		local project = findProject(config.projects, projectId)
		if not project then
			return false
		end
		if type(seconds) ~= "number" or seconds < 0 then
			return false
		end
		seconds = math.floor(seconds)

		if state.activeProjectId == projectId and state.activeStartedAt then
			state.activeStartedAt = os.time()
		end

		state.accumulated[projectId] = seconds
		notifyStateChange()
		return true
	end

	local function setContinuousElapsed(seconds)
		if type(seconds) ~= "number" or seconds < 0 then
			return false
		end
		seconds = math.floor(seconds)

		state.continuousElapsedBase = seconds
		if state.activeProjectId and state.activeStartedAt then
			state.continuousStartedAt = os.time()
		else
			state.continuousStartedAt = nil
		end
		notifyStateChange()
		return true
	end

	local function getState()
		return state
	end

	local function getSnapshot()
		local projectSnapshots = {}
		for _, project in ipairs(config.projects) do
			table.insert(projectSnapshots, {
				id = project.id,
				name = project.name,
				icon = project.icon,
				accumulated = accumulatedFor(project.id),
				isActive = state.activeProjectId == project.id,
			})
		end

		return {
			projects = projectSnapshots,
			activeProjectId = state.activeProjectId,
			currentElapsed = currentElapsed(),
			continuousElapsed = currentContinuousElapsed(),
			isRunning = state.activeProjectId ~= nil,
		}
	end

	local function tick()
		if config.onTick then
			config.onTick(state)
		end
		if config.onAlert then
			config.onAlert(state)
		end
	end

	if hs and hs.timer then
		tickTimer = hs.timer.doEvery(config.tickInterval, tick)
	end

	local function teardown()
		if tickTimer then
			tickTimer:stop()
			tickTimer = nil
		end
	end

	return {
		startProject = startProject,
		startBreak = startBreak,
		reset = reset,
		setAccumulated = setAccumulated,
		setContinuousElapsed = setContinuousElapsed,
		getState = getState,
		getSnapshot = getSnapshot,
		teardown = teardown,
		formatTime = formatTime,
	}
end

M.formatTime = formatTime

return M
