local M = {}

local DEFAULTS = {
	projects = {},
	tickInterval = 1,
}

function M.build(options)
	options = options or {}

	local config = {}

	config.tickInterval = options.tickInterval or DEFAULTS.tickInterval

	config.projects = options.projects or DEFAULTS.projects
	if type(config.projects) ~= "table" then
		error("[kokukoku.timer_engine] projects must be a table")
	end

	local projectIds = {}
	for i, project in ipairs(config.projects) do
		if type(project) ~= "table" then
			error(string.format("[kokukoku.timer_engine] projects[%d] must be a table", i))
		end
		if type(project.id) ~= "string" or project.id == "" then
			error(string.format("[kokukoku.timer_engine] projects[%d].id must be a non-empty string", i))
		end
		if type(project.name) ~= "string" or project.name == "" then
			error(string.format("[kokukoku.timer_engine] projects[%d].name must be a non-empty string", i))
		end
		if project.icon ~= nil and type(project.icon) ~= "string" then
			error(string.format("[kokukoku.timer_engine] projects[%d].icon must be a string", i))
		end
		if projectIds[project.id] then
			error(string.format("[kokukoku.timer_engine] duplicate project id: %s", project.id))
		end
		projectIds[project.id] = true
	end

	config.onStateChange = options.onStateChange
	config.onTick = options.onTick
	config.onAlert = options.onAlert
	config.initialState = options.initialState

	return config
end

return M
