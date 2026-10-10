-- Shared helpers: make sure we are in Develop with a photo, then run an action.

local LrApplication = import 'LrApplication'
local LrApplicationView = import 'LrApplicationView'
local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'

local Develop = {}

local function ensureDevelopModule()
	if LrApplicationView.getCurrentModuleName() == 'develop' then
		return true
	end

	LrApplicationView.switchToModule('develop')

	-- Module switching is asynchronous; wait up to ~2s for it to settle.
	for _ = 1, 40 do
		LrTasks.sleep(0.05)
		if LrApplicationView.getCurrentModuleName() == 'develop' then
			return true
		end
	end

	return false
end

function Develop.ensureMaskingTool()
	if LrDevelopController.getSelectedTool() ~= 'masking' then
		LrDevelopController.selectTool('masking')
	end
end

-- Runs fn() inside an async task once Develop is active and a photo is targeted.
-- Errors are surfaced as a bezel instead of a modal dialog.
function Develop.run(name, fn)
	LrTasks.startAsyncTask(function()
		if not LrApplication.activeCatalog():getTargetPhoto() then
			LrDialogs.showBezel('LrKeys: no photo selected')
			return
		end

		if not ensureDevelopModule() then
			LrDialogs.showBezel('LrKeys: could not open Develop')
			return
		end

		local ok, err = LrTasks.pcall(fn)
		if not ok then
			LrDialogs.showBezel('LrKeys: ' .. name .. ' failed')
			LrDialogs.message('LrKeys: ' .. name .. ' failed', tostring(err), 'critical')
		end
	end)
end

return Develop
