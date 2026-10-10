-- Cmd+.: show/hide the selected mask (the eye icon in the Masks panel).

local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local Develop = require 'Develop'

Develop.run('Toggle Mask Visibility', function()
	local maskId = LrDevelopController.getSelectedMask()
	if not maskId then
		LrDialogs.showBezel('LrKeys: no mask selected')
		return
	end

	LrDevelopController.toggleHideMask(maskId)
end)
