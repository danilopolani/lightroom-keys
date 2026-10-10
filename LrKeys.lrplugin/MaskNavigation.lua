-- Moves the mask selection up/down the Masks panel (like Option+Up/Down, rebound to Cmd+Up/Down).

local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local Develop = require 'Develop'

local MaskNavigation = {}

local function describe(value, depth)
	depth = depth or 0
	if type(value) ~= 'table' or depth > 2 then
		return tostring(value)
	end

	local parts = {}
	for k, v in pairs(value) do
		parts[#parts + 1] = tostring(k) .. '=' .. describe(v, depth + 1)
	end
	return '{' .. table.concat(parts, ', ') .. '}'
end

-- getAllMasks() isn't documented in detail; accept a list of ids or a list of mask tables.
local function maskIds(all)
	local ids = {}
	for _, mask in ipairs(all or {}) do
		local id = type(mask) == 'table' and (mask.id or mask.maskId or mask.ID) or mask
		if id ~= nil then
			ids[#ids + 1] = id
		end
	end
	return ids
end

function MaskNavigation.step(name, delta)
	Develop.run(name, function()
		Develop.ensureMaskingTool()

		local all = LrDevelopController.getAllMasks()
		local ids = maskIds(all)

		if #ids == 0 then
			if type(all) == 'table' and next(all) ~= nil then
				LrDialogs.message('LrKeys: unexpected mask list', describe(all), 'warning')
			else
				LrDialogs.showBezel('LrKeys: no masks')
			end
			return
		end

		local selected = LrDevelopController.getSelectedMask()
		local current
		for i, id in ipairs(ids) do
			if id == selected then
				current = i
				break
			end
		end

		local target
		if current then
			target = (current - 1 + delta) % #ids + 1 -- wrap around
		else
			target = delta > 0 and 1 or #ids
		end

		LrDevelopController.selectMask(ids[target])
	end)
end

return MaskNavigation
